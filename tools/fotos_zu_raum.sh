#!/usr/bin/env bash
# fotos_zu_raum.sh - macht aus einem Ordner mit Handyfotos ein 3D-Raummodell (PLY) fuer Winzling.
#
# Nutzung:
#   ./fotos_zu_raum.sh <fotoordner> <arbeitsordner>
#
# Voraussetzungen:
#   - COLMAP (CLI) im PATH
#   - Fuer den Dichte-Schritt (patch_match_stereo): NVIDIA-GPU mit CUDA
#   - Optional: python3 mit open3d (zum Vereinfachen des Netzes)

set -euo pipefail

if [ "$#" -ne 2 ]; then
    echo "Nutzung: $0 <fotoordner> <arbeitsordner>"
    echo "Beispiel: $0 ~/Fotos/Wohnzimmer ~/winzling-scan"
    exit 1
fi

if ! command -v colmap >/dev/null 2>&1; then
    echo "Fehler: colmap wurde nicht gefunden."
    echo "Bitte COLMAP installieren (https://colmap.github.io) und sicherstellen, dass 'colmap' im PATH liegt."
    exit 1
fi

FOTOS="$(cd "$1" && pwd)"
mkdir -p "$2"
ARB="$(cd "$2" && pwd)"
DB="$ARB/database.db"

echo "Fotos:       $FOTOS"
echo "Arbeitsordner: $ARB"
echo ""

echo "[1/9] Merkmale in den Fotos suchen (feature_extractor) ..."
colmap feature_extractor \
    --database_path "$DB" \
    --image_path "$FOTOS" \
    --ImageReader.single_camera 1 \
    --ImageReader.camera_model OPENCV

echo "[2/9] Passende Punkte zwischen allen Fotos finden (exhaustive_matcher) ..."
echo "      Hinweis: Fuer Videoframes (aufeinanderfolgende Bilder) ist 'sequential_matcher' schneller."
colmap exhaustive_matcher \
    --database_path "$DB"

echo "[3/9] Kamerapositionen und Punktwolke rekonstruieren (mapper) ..."
mkdir -p "$ARB/sparse"
colmap mapper \
    --database_path "$DB" \
    --image_path "$FOTOS" \
    --output_path "$ARB/sparse"

echo "[4/9] Ausrichten, damit 'oben' ungefaehr stimmt (model_orientation_aligner) ..."
echo "      Annahme: Die Fotos wurden aufrecht aufgenommen."
mkdir -p "$ARB/sparse/aligned"
colmap model_orientation_aligner \
    --image_path "$FOTOS" \
    --input_path "$ARB/sparse/0" \
    --output_path "$ARB/sparse/aligned"

echo "[5/9] Bilder entzerren (image_undistorter) ..."
colmap image_undistorter \
    --image_path "$FOTOS" \
    --input_path "$ARB/sparse/aligned" \
    --output_path "$ARB/dense" \
    --output_type COLMAP

echo "[6/9] Tiefenkarten berechnen (patch_match_stereo) ..."
echo "      Dieser Schritt braucht eine NVIDIA-GPU mit CUDA und kann lange dauern."
if ! command -v nvidia-smi >/dev/null 2>&1; then
    echo "      Warnung: nvidia-smi nicht gefunden. Ohne NVIDIA-GPU schlaegt dieser Schritt fehl."
fi
colmap patch_match_stereo \
    --workspace_path "$ARB/dense" \
    --workspace_format COLMAP \
    --PatchMatchStereo.geom_consistency true

echo "[7/9] Tiefenkarten zu einer dichten Punktwolke zusammenfuehren (stereo_fusion) ..."
colmap stereo_fusion \
    --workspace_path "$ARB/dense" \
    --workspace_format COLMAP \
    --input_type geometric \
    --output_path "$ARB/dense/fused.ply"

echo "[8/9] Aus der Punktwolke ein Netz machen (poisson_mesher) ..."
colmap poisson_mesher \
    --input_path "$ARB/dense/fused.ply" \
    --output_path "$ARB/dense/raum.ply"

echo "[9/9] Netz vereinfachen (optional, braucht python3 mit open3d) ..."
if python3 -c "import open3d" >/dev/null 2>&1; then
    python3 - "$ARB/dense/raum.ply" "$ARB/dense/raum_vereinfacht.ply" <<'PY' \
        || echo "      Vereinfachung ist fehlgeschlagen. Das volle Netz (raum.ply) bleibt trotzdem nutzbar."
import sys
import open3d as o3d

quelle, ziel = sys.argv[1], sys.argv[2]
MAX_DREIECKE = 800000

mesh = o3d.io.read_triangle_mesh(quelle)
vorher = len(mesh.triangles)
if vorher > MAX_DREIECKE:
    mesh = mesh.simplify_quadric_decimation(target_number_of_triangles=MAX_DREIECKE)
o3d.io.write_triangle_mesh(ziel, mesh)
print(f"      Dreiecke: {vorher} -> {len(mesh.triangles)}")
PY
else
    echo "      open3d ist nicht installiert. Vereinfachung wird uebersprungen."
    echo "      (Installation optional: pip install open3d)"
fi

echo ""
echo "Fertig!"
echo "Raum-Netz:       $ARB/dense/raum.ply"
if [ -f "$ARB/dense/raum_vereinfacht.ply" ]; then
    echo "Vereinfacht:     $ARB/dense/raum_vereinfacht.ply (empfohlen, wenn die Datei sehr gross ist)"
fi
echo ""
echo "Im Spiel kannst du die PLY-Datei ueber 'Eigenen Raum-Scan laden' einladen."
