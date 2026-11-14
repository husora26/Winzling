# Winzling

Ein Browser-Shooter aus der Ich-Perspektive, bei dem du 2 cm klein bist, mitten in deinem eigenen Zimmer. Das Zimmer kommt aus deinen Handyfotos: als schneller Foto-Raum (flache Wände aus 5 bis 6 Fotos) oder als echter 3D-Scan mit eigenen Möbeln.

## Spielen

Winzling ist ein Erkundungsspiel: Du startest im „Lager“ (dem Startpunkt), sammelst Glitzersplitter, zerstörst Fusselnester und kletterst Kapitel für Kapitel bis zum Leuchtfeuer am höchsten Punkt des Zimmers. Sterben kostet nur Zeit: Du startest nach 1,5 Sekunden wieder im Lager, der Fortschritt bleibt.

| Taste / Eingabe | Aktion |
| --- | --- |
| W A S D | Laufen (Shift: Rennen) |
| Maus | Umschauen, Linksklick schießt |
| Leertaste | Springen. An einer Kante gedrückt halten: hochziehen. In der Luft halten: Löwenzahnschirm. Am Seil: loslassen. Mit Gleiter: Tipp in der Luft klappt ihn auf und zu |
| E oder rechte Maustaste | Enterhaken werfen (ab Kapitel 2), am Seil erneut drücken: lösen |
| W / S am Seil | Einholen / Nachlassen, A D schwingen |
| V | Ego-Sicht oder Außenansicht (Mausrad zoomt) |
| Tab | Zielpfeil auf das nächste Ziel wechseln |
| R | Nachladen |
| F | Spielzeug wecken oder einschlafen lassen (am Spielzeug, oder wenn du reitest: absteigen). Auf dem Handy der Knopf „Wecken“ |
| Esc | Pause (dort: „Zurück zum Lager“, Ansicht, Grafikstufe) |

Auf dem Handy: links ein Touch-Stick zum Laufen, rechts Knöpfe für Feuer, Sprung, Haken, Gleiter, Laden, Sicht und (in der Nähe eines Spielzeugs) Wecken. Zum Umschauen wischst du auf dem Bildschirm.

### Lebendige Spielsachen

Sechs Spielzeuge liegen im Zimmer und schlafen grau. Mit **F** weckst du eins (Kosten: Funkenstaub, das erste Auto ist gratis). Pro Wecken hält es etwa 20 Sekunden Schlaf-Pause (Abklingzeit), und es kann immer nur ein von dir geweckter Helfer laufen.

| Spielzeug | Rolle |
| --- | --- |
| Flitz (Auto) | Reiten, W/S Gas, A/D lenken, Shift Boost. Feder wird verbraucht, überfährt Kabel, rammt Fussel |
| Schnurr (Aufzieh-Maus) | Lockt Fussel-Wächter von dir weg |
| Hoppel (Schaukelpferd) | Reiten, Leertaste springt hoch (Sprunghöhe nach Haltedauer) |
| Watte (Plüschbär) | Läuft mit, boxt Fussel in deiner Nähe |
| Flatter (Holzvogel) | Reiten und fliegen, ab Kapitel 3 |
| Knirsch (Gummi-Dino) | Boss: wacht auf, wenn das letzte Nest fast zerstört ist. Besiegen zähmt ihn |

Beim Reiten ist die Außenansicht fest, Haken und Gleiter sind gesperrt. **Funkenstaub** (Anzeige oben links, bis 9) gibt es von Splittern (+2), Nestern (+3), besiegten Fusseln (+1), Bonusaufgaben (+2) und für Knirsch (+3). Bonusaufgaben (T1 bis T6, etwa das Ringrennen mit dem Auto in 20 Sekunden) stehen unter dem Ziel in der Liste und sind nie Pflicht. Im Foto-Raum sitzen die Spielsachen auf den passenden Möbeln, in eigenen Scans werden sie deterministisch auf begehbaren Flächen platziert.

### Ablauf

1. **Bodenland:** 3 Glitzersplitter und das erste Fusselnest. Belohnung: der Enterhaken.
2. **Möbelgebirge:** Splitter auf Karton, Stuhl und Kissen, dazu das Nest auf der Matratze. Belohnung: der Gleiter.
3. **Gipfel:** Splitter auf Laptop und Fensterbrett, das Nest auf dem Tisch, der verlorene Ohrstecker im Regal (zurück ins Lager bringen) und das Leuchtfeuer auf dem obersten Regalbrett. Dorthin hilft der Aufwind der Schreibtischlampe.

Den Fortschritt speichert der Browser (localStorage). Im Menü steht dann „Weiter (5/13)“ und „Neu beginnen“. Eigene Raum-Scans bekommen automatisch Ziele, Nester und Aufwinde: Die Platzierung ist deterministisch (gleicher Scan, gleiche Ziele) und prüft Erreichbarkeit über Laufen, Enterhaken und Aufwind.

### Grafik

Im Menü und im Pausenmenü: **Schnell** (einfache Schatten, Pixelverhältnis 1), **Schön** (Standard am Rechner) und **Kino** (Umgebungsverdeckung, leichtes Bloom, Tiefenunschärfe, Vignette, Reflexionen, Staub im Licht, Detailtextur). Fällt die Bildrate drei Sekunden unter 25 fps, schaltet das Spiel eine Stufe zurück. Die Auswahl wird gemerkt.

## Größenverhältnisse

- Du bist 2 cm groß, deine Augen sind auf 1,75 cm.
- Für dich fühlt sich 1 cm wie etwa 87 cm für einen Menschen an.
- Ein 75 cm hoher Schreibtisch wirkt wie ein 66 m hoher Turm.

## Dein eigenes Zimmer ins Spiel holen

### Foto-Raum: schnell, direkt mit der Handykamera

„Zimmer mit der Kamera fotografieren“ im Menü baut aus 5 bis 6 Fotos ein spielbares Zimmer. Das ist **kein 3D-Scan**: Die Fotos werden als flache Tapeten auf Boden, vier Wände und (optional) Decke gelegt. Echte 3D-Möbel bekommst du nur mit einer Scan-App und „Eigenen Raum-Scan laden“ (Weg A unten).

1. Auf dem Handy öffnet „Kamera“ direkt die Kamera, ein Foto pro Platz. „aus Galerie“ nimmt ein vorhandenes Bild. Du kannst auch mehrere Bilder auf einmal wählen: Sie werden der Reihe nach auf die freien Plätze verteilt (Boden, vorne, rechts, hinten, links, Decke).
2. Boden: Handy waagrecht etwa 1 m über den Boden halten. Wände: mit dem Rücken an die gegenüberliegende Wand stellen und die ganze Wand fotografieren, Handy quer. „Vorne“ ist die Wand, zu der du beim Start schaust; rechts, hinten und links folgen im Uhrzeigersinn.
3. Trage Breite, Länge und Höhe in Metern ein (1,5 bis 15 m, Höhe 1,8 bis 5 m). Schritte zählen hilft: 1 Schritt ist etwa 0,7 m.
4. „Spielmöbel aufstellen“ stellt Bett, Schreibtisch, Regal, Rampen, Spielzeug und Aufwinde aus dem Demo-Zimmer in deinen Raum (für kleine Räume verkleinert). Ohne Möbel gibt es ein Spiel auf freiem Boden. Fehlende Fotos werden durch Putz- und Holztextur ersetzt.
5. Die Bilder werden im Browser verkleinert (höchstens 2048 px), leicht aufgehellt und auf die Wandform zugeschnitten. Der Boden wird aus dem mittleren Quadrat alle 0,8 m wiederholt (alternativ über den ganzen Boden gestreckt).
6. „Mein Foto-Zimmer“ im Menü spielt das zuletzt gebaute Zimmer ohne neue Fotos. Gespeichert wird in IndexedDB; sperrt der Browser das, läuft das Spiel trotzdem, nur ohne Speichern über das Neuladen hinaus. Der Spielstand hängt an Maßen, Möbel-Schalter und Fotos.

Deine Fotos bleiben auf diesem Gerät: Es gibt keinen Upload.


### Weg A: echter 3D-Scan (Handy oder PC)

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

- Das Spiel ist eine einzelne HTML-Datei: `index.html`. Die Spezifikation des Erkundungsmodus steht in `docs/SPEC-erkundung.md`.
- Grafik mit Three.js, Kollision der Spielfigur als Kapsel gegen das gescannte Netz mit three-mesh-bvh.
- Alles läuft lokal im Browser. Deine Fotos verlassen dein Gerät nie.
- Nur die Bibliotheken werden von einem CDN geladen.

- Debug: mit `?debug=1` in der Adresse gibt es `wz.tp(x, y, z)`, `wz.give('hook' | 'glider')` und `wz.objectives` in der Konsole. Für automatische Tests gibt es zusätzlich `window.__winzling`.

## Lokal starten

Du brauchst einen einfachen statischen Webserver. Zum Beispiel:

```
cd winzling
python3 -m http.server 8000
```

Dann öffnest du http://localhost:8000 im Browser. Für die CDN-Bibliotheken brauchst du eine Internetverbindung.
