# Winzling – Spec „Erkundung, Klettern, Ziele“ (ersetzt den Wellenmodus)

Alle Maße in Metern, Physik bleibt bei 240 Hz und `moveBody`/`resolveCapsule`. Zahlen sind Startwerte zum Tunen.

## 1. Kernschleife und Ablauf
- Start: Spieler steht am `world.spawn` (= „Lager“). Ausrüstung: Nadelschleuder und Löwenzahnschirm (heutiges Space-Halten). Kein Wellen-Timer mehr.
- Drei Kapitel, jedes mit 3–5 Zielen; das nächste Kapitel und sein Werkzeug schalten frei, sobald alle Pflichtziele des Kapitels erledigt sind:
  - Kapitel 1 „Bodenland“ (ohne Werkzeug): 3 Glitzersplitter + Nest 1. Belohnung: **Enterhaken** (erscheint an der Nest-Stelle).
  - Kapitel 2 „Möbelgebirge“ (Haken): 3 Splitter auf mittlerer Höhe + Nest 2. Belohnung: **Gleiter**.
  - Kapitel 3 „Gipfel“ (Haken + Gleiter): 2 Splitter hoch + Nest 3 + verlorenes Stück zurück ins Lager + **Leuchtfeuer** am höchsten Punkt.
- Sieg: Leuchtfeuer entzündet (5 cm Nähe, alle anderen Pflichtziele erledigt). Endbild „Zimmer bezwungen“ mit Spielzeit, Splittern x/N, Toden, Bestzeit; Knöpfe „Nochmal“ und „Frei erkunden“.
- Tod: kein Game Over. Nach 1,5 s Neustart im Lager mit 100 LP, Fortschritt bleibt, Wachen der lebenden Nester werden aufgefüllt, +1 Tod. `state.wave`/`waveTimer`/`nextWave()` und `score × wave` entfernen (Punkte: fest pro Gegner).
- Pausenmenü bekommt „Zurück zum Lager“ (Teleport) als Notausgang für Scans.

## 2. Zielsystem
Datenmodell: `world.objectives = [{ id, type, chapter, pos, tier, required, done, mesh }]`, `type ∈ splitter | nest | fund | lager | leuchtfeuer | werkzeug`. Erzeugung einmal in `startGame()` über `buildObjectives(world)`; Demo liefert die feste Liste, Scans die automatische. Abholen: Abstand Körpermitte < 1,2 cm (wie `stepCrumbs`).

**Typen**
- Glitzersplitter: drehendes Oktaeder 3 mm, emissiv, schwebt 6 mm über der Fläche, feines Funkeln.
- Nest: siehe 6. Ziel erfüllt, wenn das Nest zerstört ist.
- Verlorenes Stück („Ohrstecker“): aufnehmen, dann zum Lager tragen. Beim Tragen kein Sprint. Bei Tod liegt es wieder am Fundort.
- Leuchtfeuer: Streichholzkopf-Bake am Gipfel, bis Kapitel 3 als dunkle Silhouette sichtbar.

**Demo-Zimmer, feste Positionen (x, y = Oberkante der Fläche, z)**
| Id | Kap. | Ziel | Position | Weg |
|---|---|---|---|---|
| S1 | 1 | Splitter Teppich | (0.60, 0.003, 0.80) | laufen |
| S2 | 1 | Splitter auf Klotz „L“ | (0.43, 0.083, 0.27) | Sprung + Kantengriff über die 4-cm-Klötze |
| S3 | 1 | Splitter unterm Bett (versteckt) | (−1.75, 0, −1.20) | laufen, dunkel |
| N1 | 1 | Nest freier Boden | (−0.30, 0, −0.50) | danach Enterhaken hier |
| S4 | 2 | Splitter auf Schuhkarton | (−1.60, 0.12, −0.30) | Haken an Kartonkante |
| S5 | 2 | Splitter Stuhlsitz | (0.70, 0.47, −1.00) | Haken oder Lineal-Rampe |
| S8 | 2 | Splitter auf Kissen | (−1.50, 0.65, −1.50) | Deckenrampe, dann Haken (10 cm) |
| N2 | 2 | Nest Matratze | (−1.50, 0.55, −0.80) | danach Gleiter bei (0.80, 0.75, −1.50) auf dem Tisch |
| S6 | 3 | Splitter auf Laptop | (1.20, 0.766, −1.45) | Kantengriff (1,6 cm) |
| S7 | 3 | Splitter Fensterbrett | (0.60, 1.07, −1.71) | Haken vom Tisch (0,32 m hoch) |
| N3 | 3 | Nest Tisch | (1.35, 0.75, −1.20) | |
| F1 | 3 | Ohrstecker Regalbrett 3 | (1.73, 1.225, −0.25) | Haken von Tischecke (1.58, 0.75, −1.07): ≈ 0,95 m; Rückweg per Gleiter |
| L | – | Lager | (0.10, 0.003, 0.60) | = Spawn |
| G | 3 | Leuchtfeuer Regal oben | (1.86, 2.005, 0.15) | Lampen-Aufwind bis ~1,85 m, anfliegen, Haken an Oberkante |

Jede Position beim Start mit `hasClearance` prüfen; schlägt sie fehl, per `findWalkable(pos, 0, 0.05, [-0.02, 0.02])` nachrücken und in der Konsole warnen.

**Scans, automatische Platzierung** (deterministisch: `seeded(hash(roomId))`, kein `Math.random`)
1. Raster über `w.inner`, Abstand g = clamp(√(Fläche/1600), 0.06, 0.15), je Zelle ein senkrechter Strahl von oben, alle Treffer (`bvh.raycast`, wie `findWalkable`).
2. Kandidat, wenn: |normal.y| > 0,65, `hasClearance`, Kopffreiheit ≥ 3 cm, Fläche eben (4 Nachbarproben in ±1,5 cm treffen innerhalb ±4 mm Höhe), Höhe ≤ floorY + 0,85 × Raumhöhe.
3. Stufe nach Höhe über `floorY`: Boden < 0,06 · Mitte 0,06–0,60 · Hoch > 0,60. „Versteckt“ = Boden und Deckentreffer in 0,03–0,35 m.
4. Erreichbarkeit:
   - Boden: Breitensuche ab Spawn über Rasternachbarn; Kante gilt, wenn alle Proben im 2-cm-Abstand `hasClearance` haben und der Höhensprung ≤ 3 cm ist.
   - Haken: Kandidat S gilt als erreichbar, wenn von einem erreichbaren R gilt: Abstand ≤ 1,1 m, freie Sicht von R+Auge zu S+1,5 cm, und der Probe-Hakenwurf auf S−5 mm einen Kantenanker (3.) höchstens 2 cm von S liefert. Bis zu 3 Durchläufe (Ketten).
   - Aufwind-Garantie: für nicht beweisbare Hoch-Ziele wird ein Aufwind gesetzt: Bodenpunkt 0,4–0,9 m horizontal entfernt, senkrecht frei bis Ziel.y + 0,3 m, freie Sicht von der Säulenspitze zum Ziel. Höchstens 3 Aufwinde; solche Ziele kommen in Kapitel 3.
5. Auswahl je Stufe per Farthest-Point (Mindestabstand 0,35 m untereinander, 0,4 m zum Spawn). Anzahl Splitter N = clamp(round(0,6 × Bodenfläche m²), 5, 10), verteilt 3 / ⌈Rest/2⌉ / Rest; mindestens ein versteckter in Kapitel 1, falls vorhanden.
6. Nest je Kapitel auf ebenem Fleck mit `sphereFree(…, 0.012)`; Fund = versteckter Bodenpunkt, am weitesten vom Spawn; Leuchtfeuer = höchster erreichbarer Kandidat.
7. Rückfall: fehlt eine Stufe, wandern ihre Ziele eine Stufe tiefer; nicht beweisbare Kandidaten werden höchstens Bonus-Splitter (`required: false`). Minimum: 3 Boden-Splitter + Leuchtfeuer am höchsten erreichbaren Punkt.

## 3. Enterhaken
- Auslösen: Taste **E** oder rechte Maustaste (`contextmenu` unterdrücken), Touch-Knopf „Haken“. Hitscan aus der Kamera, Reichweite **1,2 m**, Mindestabstand 3 cm (sonst Fehlton). Gegner sind kein Ankerziel.
- Zielhilfe: zusätzlich 8 Strahlen im 2,5°-Kegel; bevorzugt wird der Treffer, der einen Kantenanker ergibt, sonst der Mittelstrahl. Fadenkreuz wird grün, wenn ein Anker in Reichweite ist (Kantenprobe alle 0,1 s).
- Kantenanker: Treffer H mit |n.y| < 0,5 → Strahl abwärts von (H − n_horizontal·6 mm, y = H.y + 3,5 cm), Länge 4,5 cm; trifft er eine Fläche T mit n.y > 0,65 und `hasClearance(T)`, wird der Anker auf die Lippe (H.x, T.y, H.z) gesetzt und `hook.ledge = T` gemerkt. Jede andere Fläche ist ein normaler Anker: man hängt.
- Zustände: `idle → fliegt (0,08 s, nur optisch) → fest → idle`. Abklingzeit 0,6 s nach Lösen, 0,3 s nach Fehlwurf.
- Physik: eigener Zweig `stepHooked(h)` in `stepPlayer`, Seilpunkt = Brust (pos + 1,2 cm), positionsbasiert:
  1. `vel.y −= g·h`; `vel *= exp(−0,4·h)`; Schwunggabe aus Eingabe 0,8 m/s² (quer zum Seil).
  2. Seillänge L: automatisch einholen mit **0,9 m/s** bis L_min = 1,2 cm (Decke/Unterseite: 2 cm). S/Stick zurück: nachlassen 0,4 m/s bis 1,2 m. Ohne Einholen: Pendel mit fester Länge.
  3. Ziel p' = p + vel·h; ist |p' − Anker| > L, auf die Kugel zurückprojizieren. `moveBody(…, p' − p, …)`; danach `vel = (pos_neu − pos_alt)/h`, nach außen gerichteten Radialanteil streichen, |vel| auf **1,6 m/s** kappen.
  4. Kontakt: Geschwindigkeitsanteil in die Fläche streichen.
- Ankunft: L ≤ L_min und `hook.ledge` gesetzt → automatischer Kantengriff (5.) auf T, Haken löst sich. Ohne Kante: hängen bleiben.
- Lösen: **Leertaste** = lösen mit Absprung (+0,45 m/s nach oben, Schwung bleibt); **E** erneut = lösen ohne Impuls; Bodenkontakt bei nicht einholendem Seil = lösen.
- Randfälle: Einholen 0,5 s ohne Fortschritt → Einholen stoppen. Sicht Brust→Anker länger als 0,6 s blockiert → „Seil gerissen“, lösen. Weltwechsel, Tod, Menü: Haken zurücksetzen. Schießen bleibt am Seil möglich.
- Darstellung: `THREE.Line` (8 Punkte, Durchhang bei schlaffem Seil, `frustumCulled = false`) von `muzzleWorld()` zum Anker, hell-beige, kleiner Widerhaken-Kegel am Anker. Eigene Scratch-Vektoren verwenden.

## 4. Gleiter (löst den Schirm ab, sobald freigeschaltet)
| | Löwenzahnschirm (Start) | Gleiter (Kapitel 3) |
|---|---|---|
| Bedienung | Space halten beim Fallen | Space-Tipp in der Luft klappt auf/zu (Touch: Knopf „Gleiter“) |
| Sinken | 0,11 m/s | 0,16 m/s (neutral) |
| Vorwärts | nur Luftsteuerung | 0,55 m/s, Gleitzahl ≈ 3,4 |
| Steuern | wie Laufen | Blickrichtung |
- Aufklappen: mindestens 0,15 s in der Luft und kein Boden innerhalb 3 cm. Zuklappen: Tipp, Bodenkontakt, Hakenwurf-Treffer, Frontalaufprall.
- Eigener Zweig `stepGlide(h)`, Zustand `glide = { v, heading, stallT }`:
  - Kurs dreht mit max. 2,2 rad/s auf `state.yaw`.
  - Zielfahrt v_soll = clamp(0,55 − 0,45·sin(pitch), 0,20, 0,95); v nähert sich mit 0,6 m/s².
  - Sinken = 0,16 + 0,6·max(0, −sin pitch) − 0,25·max(0, sin pitch)·clamp((v − 0,30)/0,25, 0, 1).
  - Strömungsabriss: v < 0,26 → 0,5 s lang Sinken 0,7 m/s, keine Kurssteuerung, v_soll 0,5; Warnton und Kamerarütteln.
  - `vel = (−sin(heading)·v, −Sinken + Auftrieb, −cos(heading)·v)`, vertikal mit Rate 4/s angeglichen; `moveBody(vel·h)`.
  - Landung (Kontakt n.y > 0,6): zuklappen, 30 % der Fahrt als auslaufender Schub. Wandkontakt: Fahrt in die Wand streichen; bleibt v < 0,15 → zuklappen und fallen. Kein Fallschaden.
- Aufwinde: `world.updrafts = [{ x, z, r, y0, y1, lift }]`, Auftrieb voll im Kern, linear auf 0 am Rand; wirkt auch auf den Schirm (halbe Stärke). Sichtbar als langsam aufsteigende Staubpunkte.
  - Demo: Lampe (1.36, −1.42), r 0,28, y 0,77–1,90, lift 0,50 · Laptop (1.20, −1.50), r 0,18, y 0,77–1,20, lift 0,30 · Sonnenfleck Teppich (0.10, 0.60), r 0,25, y 0–0,60, lift 0,28.
  - Scans: nur die Aufwinde aus der Aufwind-Garantie (2.4), lift 0,50, r 0,28.
- Kamera: Rollwinkel = −clamp(Kursrate·0,12, ±0,35), geglättet; Sichtfeld 78° → 86° mit Fahrt; Waffe abgesenkt, zwei Blattrippen des Gleiters am oberen Bildrand.

## 5. Kletterhilfen
- **Kantengriff**: Sprungtaste gedrückt (Flanke oder gehalten in der Luft), Bewegung zur Wand. Probe: Strahl vorwärts ab Brust, Länge r + 6 mm, trifft Wand (|n.y| < 0,3); dann Strahl abwärts von (pos + vorwärts·(r + 8 mm), y = pos.y + 3,2 cm). Gültig, wenn Oberkante 0,6–3,0 cm über den Füßen, n.y > 0,65, `hasClearance` oben und Kapsel beim Anheben frei. Ablauf 0,35 s kinematisch (60 % hoch, 40 % vor), Eingabe gesperrt, Waffe unten.
- **Faserklettern**: nicht in Version 1 für Scans. Optional nur im Demo über `world.climbZones`. Letzter Punkt der Bauliste.

## 6. Gegner in der Erkundung
- Nest: Fusselknäuel-Kugel r 1,2 cm, 8 LP, per Nadel zerstörbar, pulsiert. Startwachen: Kapitel 1 = 2 Fussel; Kapitel 2 = 2 Fussel + 2 Milben; Kapitel 3 = 3 Fussel + 3 Milben, platziert mit `findWalkable(nest, 0.05, 0.25, [-0.03, 0.03])` + `sphereFree`.
- Wachverhalten: `e.home`, Patrouille im 0,25-m-Radius mit 40 % Tempo. Alarm, wenn Spieler < 0,6 m und Höhenunterschied < 0,15 m, oder bei Treffer (dann 6 s). Verfolgung endet bei > 0,9 m vom Nest → Rückkehr. Die 10-s-Umsetzregel setzt auf `home`.
- Nachschub: solange das Nest lebt, alle 12 s eine Wache, wenn < Startzahl und Spieler 0,15–1,5 m entfernt. Zerstörtes Nest: keine Gegner mehr dort (gespeichert), lässt 2 Krümel + 1 Nadelkissen fallen.
- Streuner: je Kapitel 2 einzelne Milben an Boden-Kandidaten, kein Nachschub.
- Munition: Reserve 48 Nadeln (max. 96), Magazin 16; Nadelkissen +16. Reserve leer: 1 Nadel alle 4 s. Krümel +20 LP; je Kapitel 3 Krümel und 2 Nadelkissen an erreichbaren Punkten, zusätzlich 30 % Krümel-Drop.

## 7. HUD und Bedienung
- `#wave-line` wird Zielanzeige: „Kapitel 2 · Möbelgebirge“ + Liste (max. 4 Zeilen, erledigte abgehakt), Splitter x/N.
- Zielpfeil: nächstes offenes Pflichtziel per `Vector3.project(playCam)`; im Bild: kleine Raute mit Entfernung („42 cm“); außerhalb: Pfeil am Bildrand plus ▲/▼ und Höhenunterschied. Taste **Tab** wechselt das verfolgte Ziel.
- Hinweise ohne Karte: Funkeln der Splitter, Nest-Summen (Lautstärke nach Abstand), Toast beim ersten Ziel jeder Stufe.
- Werkzeugleiste unten Mitte: Haken (Ring füllt sich in der Abklingzeit; grün bei gültigem Anker), Gleiter (aktiv/aus; „Abriss“ blinkt), gesperrte Werkzeuge ausgegraut. Munition als „16 / 48“.
- Touch: neue Knöpfe `#t-hook` und `#t-glide` via `holdBtn`; am Seil löst „Sprung“. Tastatur: E Haken, Space Sprung/Griff/Gleiter/Lösen, Tab Zielwechsel; Menü- und Pausentext aktualisieren.

## 8. Fortschritt (localStorage)
- Schlüssel `winzling.v1.<roomId>`; Demo: `demo`; Scan: Dateiname + Dreieckszahl + Bounding-Box-Maße in mm nach Kalibrierung.
- Inhalt: `{ v: 1, done: [ids], chapter, tools: { hook, glider }, ammoReserve, time, deaths, best, won }`. Speichern bei jedem erledigten Ziel und beim Sieg; laden in `startGame()`. Alles in `try/catch`. Menü zeigt „Weiter (5/13)“ und „Neu beginnen“.
- Position wird nicht gespeichert (Start immer im Lager).

## 9. Außenansicht und Grafikstufen (Nachtrag, Wunsch von Alex)
- **Außenansicht**: Taste **V** (Touch: Knopf „Sicht“) wechselt zwischen Ego-Sicht und Verfolgerkamera. In der Außenansicht ist eine sichtbare Spielfigur zu sehen (2 cm, einfache gegliederte Figur mit Kopf, Rumpf, Armen, Beinen, Nadelschleuder, Laufanimation; Schirm/Gleiter/Seil an der Figur sichtbar). Kamera: Schulterblick, Abstand 6 cm hinter und 2,5 cm über der Figur, per Mausrad/Pinch 3–20 cm; Kamerakollision per Strahl gegen die BVH (Kamera rückt heran statt durch Wände zu schauen). Steuerung bleibt gleich (Maus dreht, WASD relativ zur Blickrichtung); geschossen wird aus der Figur auf den Punkt unter dem Fadenkreuz. Die Ego-Waffe wird in der Außenansicht ausgeblendet. Einstellung wird gemerkt.
- **Grafikstufen**: umschaltbar im Menü und Pausenmenü: „Schnell“, „Schön“, „Kino“. Schnell: kein Schatten-Soft, Pixelverhältnis 1, kein Post-Processing. Schön (Standard Desktop): wie bisher. Kino: Post-Processing über three/addons `EffectComposer` (Umgebungsverdeckung GTAO oder SAO, leichtes Bloom, Tiefenunschärfe passend zum Miniatur-Maßstab, Vignette, Farbkorrektur via OutputPass), prozedurale Umgebungs-Map (`RoomEnvironment` + PMREM) für Reflexionen, Staubpartikel im Sonnenlicht, feinere Detailtexturen (Detail-Map für Boden/Teppich). Automatischer Rückfall auf die nächstniedrigere Stufe, wenn die Bildrate 3 s unter 25 fps liegt. Auswahl in localStorage gemerkt.

## 10. Bauliste (Reihenfolge)
1. Wellenmodus ausbauen, Zustände `hook`/`glide`/`mantle`, Werkzeug-Flags, Debug-Schalter `?debug=1` (`wz.tp(x,y,z)`, `wz.give('hook'|'glider')`, `wz.objectives`).
2. Zielsystem mit Demo-Liste, Abholen, Kapitel-Logik, Sieg, Zielanzeige.
3. Kantengriff. 4. Enterhaken. 5. Gleiter + Aufwinde + Kamera.
6. Nester, Wachverhalten, Munition/Pickups. 7. Zielpfeil, Werkzeugleiste, Touch-Knöpfe.
8. Scan-Generator. 9. Speichern. 10. Außenansicht mit Spielfigur. 11. Grafikstufen. 12. Optional: Faserklettern im Demo.

## 11. Prüfliste
- Haken Boden→Tisch: von (0.40, 0, −0.80) auf die Tischkante (z = −1,05), Abstand ≈ 0,76 m; nach ≤ 1,5 s steht der Spieler auf y = 0,75 ± 0,005.
- Haken-Reichweite: Treffer bei 1,19 m haftet, bei 1,25 m nicht; unter 3 cm Fehlton.
- Kein Tunneln: 20 Würfe gegen Wand, Decke, Tischunterseite bei 30 und 240 fps; nie in Geometrie, Tempo nie > 1,6 m/s.
- Gleiter vom Tisch: Start (0.90, 0.75, −1.06), Kurs +z, Blick waagrecht: Landung ≥ 1,5 m entfernt. Blick 30° nach unten: kürzer. Blick 50° nach oben: Abriss innerhalb 2 s.
- Lampen-Aufwind: von 0,8 m auf ≥ 1,8 m in ≤ 6 s; von dort Regaldach (y 2,005) mit Haken erreichbar. Sonst `y1`/`lift` erhöhen.
- Kantengriff: Klotz 4 cm per Sprung+Griff ja; 7-cm-Kante nein; nie in Geometrie.
- Demo: alle 14 Positionen bestehen `hasClearance`; kompletter Durchlauf ohne Debug möglich; Kapitel 1 ohne Werkzeug lösbar.
- Scan: alle erzeugten Ziele auf begehbaren Flächen, paarweise ≥ 0,35 m; zweimal laden ergibt identische Ziele; Erzeugung < 300 ms bei 400 000 Dreiecken; Scan nur mit Boden ergibt gültiges Minimalspiel.
- Gegner: Wachen nie > 1,0 m vom Nest; nach Nest-Zerstörung kein Nachschub; Reserve 0 → Nadeln kommen nach.
- Speichern: 2 Ziele holen, neu laden → beide erledigt; blockiertes `localStorage` → Spiel läuft ohne Fehler.
- Außenansicht: Kamera schaut nie durch Wände; Schuss trifft den Punkt unter dem Fadenkreuz; Umschalten mitten im Flug/am Seil ohne Fehler.
- Grafikstufen: alle drei Stufen ohne Konsolenfehler; Umschalten im laufenden Spiel; Rückfall bei niedriger Bildrate.
- Touch: Haken, Gleiter, Sicht per Knopf bedienbar; 60 s Spiel ohne Konsolenfehler.
