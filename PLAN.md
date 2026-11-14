# Winzling – Plan für die nächsten Schritte

**M1 – Aus der Einzeldatei ins Repo (S–M).** Vite mit Three.js und three-mesh-bvh als npm-Pakete; Module core/, physics/, world/, game/, ui/, audio/; Vitest für Kapselkollision, Perzentil, Ebenen-Fit; ein Playwright-Smoke-Test.

**M2 – Import ohne Handarbeit (M).** RANSAC-Ebenen-Fit erkennt Boden, Hochachse und Bodenhöhe; Wände richten den Raum aus; Maßstab über Deckenhöhe (2,4–2,6 m) oder Zwei-Punkt-Messung (z. B. Türhöhe); Draco/KTX2-Decoder; kalibrierte Räume in IndexedDB speichern ("Meine Räume").

**M3 – Scan-Aufbereitung und Handy-Leistung (M–L).** Im Web Worker bereinigen (Vertices verschweißen, lose Inseln entfernen), Kollisions-Mesh auf 150–300k Dreiecke vereinfachen, Darstellung in Kacheln mit LOD, BVH zwischenspeichern; Ziel 60 fps Desktop, 30 fps Mittelklasse-Handy.

**M4 – Spiel, das die Winzigkeit nutzt (L).** Begehbarkeitsanalyse des Scans → Navigationsgraph mit Sprung- und Fallkanten, Gegner mit A*; automatisch erkannte Verstecke, Aussichtspunkte, Ziele ("erreiche das Regal"); Stufenhilfe gegen Scan-Rauschen, Klettern, Aufwind zum Gleiten, fliegende Gegner.

**M5 – Fotos direkt im Spiel (L, optional).** Eigener Dienst: Fotos/Video hochladen → GPU-Rekonstruktion (COLMAP/GLOMAP + Mesh) → GLB und optional Gaussian Splat für die Optik über einem unsichtbaren Kollisions-Mesh. Bewusst zuletzt (Kosten, Datenschutz, Aufwand).

## Risiken und Gegenmittel
- **Löcher im Scan:** unsichtbare Bodenebene und Raum-Quader als Auffangnetz, Zurücksetzen beim Durchfallen (schon drin).
- **Rauschen von 0,5–2 cm** ist für einen 2-cm-Winzling hüfthoch: Kollisions-Mesh glätten, große Flächen auf gefittete Ebenen einrasten, Stufenhilfe.
- **Dünne/einseitige Flächen:** Schrittweite an Geschwindigkeit koppeln, "im Inneren gefangen" erkennen.
- **Maßstab unklar** bei Fotogrammetrie ohne LiDAR: Plausibilitätsprüfung und Zwei-Punkt-Messung.
- **Speicher auf Handys:** M3 plus harte Obergrenze mit klarer Meldung.

## Entscheidungen für Alex
- Eigener Rekonstruktionsdienst oder weiter fremde Scan-Apps?
- Datenschutz: dürfen Fotos/Scans des Zimmers das Gerät verlassen?
- Handy zuerst oder Desktop zuerst?
- Spielrichtung: Wellen-Shooter oder Erkundung mit Zielen und Klettern?
- Echte Physik (9,81 m/s²) oder bewusst spielerischer?
- Veröffentlichung: privat oder öffentlich, Open Source, Hosting, Repo.
