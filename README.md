# Winzling

Ein Browser-Shooter aus der Ich-Perspektive, bei dem du 2 cm klein bist, mitten in deinem eigenen Zimmer. Die Wände, Möbel und der Boden kommen aus echten Handyfotos, die in 3D nachgebaut werden.

## Spielen

| Taste / Eingabe | Aktion |
| --- | --- |
| W A S D | Laufen |
| Maus | Umschauen |
| Linksklick | Schießen |
| Leertaste | Springen. In der Luft gedrückt halten zum Gleiten |
| Shift | Rennen |
| R | Nachladen |
| Esc | Pause |

Auf dem Handy: links ein Touch-Stick zum Laufen, rechts Buttons für Schießen, Springen, Rennen und Nachladen. Zum Umschauen wischst du auf dem Bildschirm.

## Größenverhältnisse

- Du bist 2 cm groß, deine Augen sind auf 1,75 cm.
- Für dich fühlt sich 1 cm wie etwa 87 cm für einen Menschen an.
- Ein 75 cm hoher Schreibtisch wirkt wie ein 66 m hoher Turm.

## Dein eigenes Zimmer ins Spiel holen

### Weg A: einfach (Handy oder PC)

1. Installiere eine Scan-App mit Fotomodus, zum Beispiel Polycam, Scaniverse oder KIRI Engine.
2. Gehe langsam durch dein Zimmer und mache 60 bis 200 Fotos, die sich überlappen. Fotografiere auch tief, nah am Boden.
3. Exportiere das Ergebnis als GLB, OBJ oder PLY. Wichtig: Es muss ein Netz (Mesh) sein, keine Punktwolke. Draco-Komprimierung solltest du deaktivieren.
4. Lade die Datei im Spiel hoch.
5. Richte den Raum mit den Neigungs-Buttons aus, damit der Boden auf dem Raster liegt.
6. Trage die längste Raumseite in Metern ein. Bei LiDAR-Scans kannst du stattdessen „schon in echten Metern“ ankreuzen.
7. Tippe einen Startpunkt an und spiel los.

### Weg B: frei (PC mit Nvidia-GPU)

Das Skript `tools/fotos_zu_raum.sh` baut mit COLMAP aus deinen Fotos ein Raummodell.

```
./tools/fotos_zu_raum.sh <fotoordner> <arbeitsordner>
```

- Du brauchst COLMAP (CLI) im PATH und für den Dichte-Schritt eine Nvidia-GPU mit CUDA.
- Das Ergebnis liegt danach unter `<arbeitsordner>/dense/raum.ply` (oder `raum_vereinfacht.ply`, falls open3d installiert ist).
- Lade die PLY-Datei im Spiel über „Eigenen Raum-Scan laden“.
- Der Ablauf dauert je nach Fotozahl und GPU einige Stunden.

Hinweis: Das Skript kann auf dem Rechner, auf dem wir es geschrieben haben, nicht getestet werden. Beim ersten Lauf kann es also Anpassungen brauchen.

## Technik

- Das Spiel ist eine einzelne HTML-Datei: `index.html`.
- Grafik mit Three.js, Kollision der Spielfigur als Kapsel gegen das gescannte Netz mit three-mesh-bvh.
- Alles läuft lokal im Browser. Deine Fotos verlassen dein Gerät nie.
- Nur die Bibliotheken werden von einem CDN geladen.

## Lokal starten

Du brauchst einen einfachen statischen Webserver. Zum Beispiel:

```
cd winzling
python3 -m http.server 8000
```

Dann öffnest du http://localhost:8000 im Browser. Für die CDN-Bibliotheken brauchst du eine Internetverbindung.
