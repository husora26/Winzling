# Winzling – Spec „Lebendige Spielsachen“ (Nachtrag zu SPEC-erkundung.md)

Alle Maße in Metern, Physik bei 240 Hz über `moveBody`/`stepBody`. Zahlen sind Startwerte zum Tunen.

## 1. Grundidee
- Im Zimmer liegen 6 schlafende Spielsachen (grau entsättigt, langsames „Atmen“ ±2 %). Der Spieler weckt sie bei Bedarf mit **Funkenstaub**; wach leuchten Augen/Schlüssel, bis die **Aufziehfeder** (Energie in Sekunden) abgelaufen ist.
- Höchstens 1 vom Spieler gewecktes Spielzeug gleichzeitig (plus ggf. der Dino als Gegner). Ein zweites Wecken legt das erste schlafen.
- Datenmodell: `world.toys = [{ id, kind, home, yaw, chapter, cost, energy, maxEnergy, state: 'schlaf'|'wach'|'boss', body: { pos, vel, r, y0, y1, onGround, canStep: false }, mesh, found, cd }]`, Konstanten in `TOYS = { flitz: {...}, ... }`.

## 2. Spielsachen (prozedural aus Box/Cylinder/Sphere/Cone, flatShading, je ≤ 25 Meshes in einer Group)
| Id | Aussehen und Größe (L × B × H) | Rolle | Körper | Kosten / Feder | ab Kap. |
|---|---|---|---|---|---|
| `flitz` Auto | 0,10 × 0,045 × 0,04; roter Keil, 4 Zylinderräder, gelber Aufziehschlüssel am Heck | Fahrzeug zum Mitfahren | Kugel r 0,022 | 2 / 25 s | 1 |
| `schnurr` Aufziehmaus | 0,06 × 0,03 × 0,03; grauer Halbellipsoid, Filzohren, Schnurschwanz, Schlüssel seitlich | Lockvogel für Wachen | Kugel r 0,015 | 1 / 15 s | 1 |
| `hoppel` Schaukelpferd | 0,14 × 0,05 × 0,12; Holzklotz-Rumpf, Kufen aus Torus-Segmenten, Wollmähne | Sprung-Reittier | Kapsel r 0,025, y0 0,025, y1 0,07 | 3 / 30 s | 2 |
| `watte` Plüschbär | sitzend 0,08 × 0,08 × 0,12; Kugeln, Flicken auf dem Bauch, Knopfaugen | Begleiter, kämpft gegen Wachen | Kugel r 0,035 | 3 / 40 s | 2 |
| `flatter` Holzvogel | 0,07 lang, Spannweite 0,09, H 0,04; Kegelrumpf, zwei Brettflügel an Gelenken, Stoffschwanz | Flug-Reittier, trägt nach oben | Kugel r 0,02 | 4 / 22 s | 3 |
| `knirsch` Gummi-Dino | 0,12 × 0,04 × 0,09; grün, Zackenkamm aus Kegeln, Klappkiefer | vom Nest geweckter Mini-Boss, danach zähmbar | Kapsel r 0,02, y0 0,02, y1 0,06 | (5 / 30 s nach Zähmung) | 3 |

**Gemeinsame Physik**
- Spielsachen sind **nicht** in der BVH. Welt-Kollision: eigener Körper `b` über `stepBody(bvh, b, hd, h, term)` im 240-Hz-Schritt neben `stepEnemyPhysics`. Zusätzlich „Nasenstrahl“: `bvh.raycast` aus der Körpermitte in Fahrtrichtung, Länge halbe Länge + 5 mm; Treffer mit |n.y| < 0,5 stoppt die Vorwärtsfahrt.
- Spieler gegen Spielzeug: 1–2 Kugeln je Spielzeug (Radius = Körperradius), nur horizontales Herausschieben des Spielers. Kein Hakenanker, kein Draufstehen in Version 1.
- Kantenprobe für KI (Bär, Maus, Dino): Strahl abwärts 3 cm voraus, kein Boden innerhalb 4 cm → abdrehen. Reiten darf über Kanten fahren (kein Fallschaden).
- Reiten: `state.riding = toy`. Spielerkapsel wird nicht simuliert, `state.pos = toy.body.pos + Sitzversatz`; Haken, Gleiter, Kantengriff gesperrt, Schießen erlaubt. Kamera erzwingt die Außenansicht (vorherige Sicht merken), Abstand = 2,5 × Spielzeuglänge, Kamerakollision wie gehabt. Schaden durch Wachen beim Reiten × 0,5.
- Absteigen (F, Feder leer, Tod, Menü, Weltwechsel): Spieler per `findWalkable(toy.pos, r + 0,01, r + 0,06, [-0.02, 0.03])` daneben setzen; in der Luft: am Ort absetzen, Schirm/Gleiter wieder frei.

**Einzelregeln**
- **Flitz**: W/S Gas/Rückwärts, A/D lenken (2,4 rad/s × Fahrtanteil), Maus nur Kamera. v_max 0,9 m/s vorwärts, 0,3 rückwärts, Beschleunigung 1,8 m/s², Ausrollen 1,2 m/s². Shift = Schub 1,3 m/s, Feder läuft doppelt. Rammt Gegner ab 0,4 m/s: 3 Schaden und Rückstoß. Rollt über Teppichkante (3 mm) und Kabel (6,7 mm); Stufen > 1 cm blocken.
- **Schnurr**: läuft selbstständig mit 0,35 m/s zum nächsten lebenden Nest innerhalb 2,5 m (gleiche Höhe ±0,15) und kreist dort im Radius 0,2 m. Wachen im Umkreis 0,5 m verfolgen die Maus statt des Spielers (`e.lure`), sie nimmt keinen Schaden. Ohne Nest in Reichweite: läuft zum nächsten offenen Boden-Ziel und hinterlässt eine Funkenspur.
- **Hoppel**: W/S, Lenkung über Blickrichtung, 0,45 m/s. Leertaste halten lädt 0–0,8 s, Loslassen springt mit vy 1,2–3,3 m/s (Höhe 7–55 cm). Jeder Sprung kostet 2 s Feder. Landung mit Staubwolke, kein Schaden. Alternative zum Haken für Stuhl und Schuhkarton.
- **Watte**: folgt dem Spieler auf 0,15 m mit 0,20 m/s; greift Gegner im Umkreis 0,5 m an: Hieb 3 Schaden alle 0,9 s, Reichweite 4 cm, Nest 1 Schaden je Hieb. Wachen im Umkreis 0,3 m wählen zu 50 % den Bären als Ziel; jeder Treffer kostet ihn 3 s Feder. Spieler > 1,2 m entfernt oder Höhenunterschied > 0,3 m länger als 3 s → Bär schläft ein.
- **Flatter**: Kurs = Blickrichtung (max. 2,5 rad/s), W vorwärts 0,6 m/s, S schweben, Leertaste halten = Steigen 0,35 m/s, sonst Sinken 0,10 m/s. Keine Schwerkraft, Bewegung über `moveBody`; Deckel bei `inner.max.y − 0,05`. Feder leer: Sinkflug 0,25 m/s bis zum Boden, dann absteigen. Aufwinde wirken zusätzlich.
- **Knirsch** (Boss): 30 LP, 0,12 m/s, Biss 25 Schaden (Abklingzeit 1,2 s, Reichweite 3 cm), alle 6 s Anlauf 0,45 m/s über 0,5 s mit 0,6 s Ankündigung (Kiefer klappert, rote Augen). Bleibt per Kantenprobe auf seiner Fläche und höchstens 0,6 m vom Nest. LP-Balken über dem Kopf.

## 3. Wecken und Einschlafen
- **Funkenstaub** (`state.staub`, max. 9, Start 2): Splitter +2, Nest +3, besiegter Gegner +1, Knirsch +3.
- **Spieler weckt**: Abstand < 6 cm und `state.chapter ≥ toy.chapter` (in „Frei erkunden“ alle) → Hinweis „F: Flitz wecken (2 Funkenstaub)“. **F** / Touch-Knopf „Wecken“ zieht die Kosten ab, 0,6 s Aufwach-Animation (Schlüssel dreht, Funkenwolke), bei Fahrzeug/Reittier steigt der Spieler direkt auf. Zu wenig Staub: Fehlton + „Funkenstaub fehlt (1/2)“. Zu früh: „Schläft noch tief (Kapitel 2)“.
- Erstes Wecken von Flitz ist kostenlos (Einführungs-Toast). Erneutes Wecken desselben Spielzeugs frühestens nach 20 s.
- Feder läuft nur, solange wach; unter 5 s blinkt die Anzeige und der Schlüssel tickt hörbar.
- **Einschlafen**: Feder 0, F beim Reiten, Tod, Weltwechsel. Spielzeug bleibt am Ort liegen; bei Respawn, „Zurück zum Lager“ und Neuladen liegen alle wieder am `home`.
- **Das Spiel weckt**: Fällt Nest N3 (Scans: Nest des Kapitels 3) erstmals auf ≤ 4 LP, fliegt eine Funkenbahn zu Knirsch, er erwacht nach 1 s als Boss, Toast „Das Nest weckt den Dino!“. Solange er wach ist, nimmt das Nest halben Schaden. Er schläft ein, wenn seine LP 0 sind oder das Nest zerstört ist; danach ist er **gezähmt** und für 5 Staub als Begleiter weckbar (wie Watte, Biss 5 Schaden, 0,15 m/s). Bei Tod des Spielers: Knirsch schläft, LP voll, erwacht erneut beim nächsten Treffer auf das Nest.
- `wakeToy(toy, by)` mit `by ∈ 'spieler' | 'nest' | 'ziel'`.

## 4. Platzierung
**Demo-Zimmer** (x, y = Oberkante der Fläche, z)
| Id | Position | Anker | Ort |
|---|---|---|---|
| flitz | (0.30, 0, −0.40), Blick −x | Mitte | freier Boden zwischen Teppich und Stuhl |
| schnurr | (−1.30, 0, −0.95) | Bett | unter dem Bett |
| hoppel | (0.80, 0, 1.35) | Mitte | Boden vor dem Teppich nahe der Tür |
| watte | (−1.65, 0.59, 0.70) | Bett | auf der Bettdecke |
| flatter | (0.70, 0.75, −1.38) | Tisch | Tischplatte |
| knirsch | (1.48, 0.75, −1.22) | Tisch | Tischplatte neben Nest N3 |
- Beim Start je Position `sphereFree` prüfen, sonst per `findWalkable` nachrücken und warnen; ≥ 8 cm Abstand zu jedem Ziel.
- **Foto-Raum**: gleiche Liste über dieselbe Anker-Transformation wie die Möbel (Hilfsfunktion `furniturePoint`). Spielzeug-Maßstab bleibt 1, danach derselbe Freiraum-Test.
- **Scans**: aus den erreichbaren Kandidaten von `generateScanObjectives` mit `seeded(hash(roomId) + 77)`: Flitz, Schnurr, Hoppel auf Boden-Kandidaten; Watte und Flatter auf Mitte-Kandidaten, sonst Boden; Knirsch nahe Nest 3. Bedingungen: `sphereFree`, Kopffreiheit ≥ Höhe + 1 cm, ebene Fläche, ≥ 0,35 m zu anderen Spielsachen, ≥ 0,25 m zu Zielen, ≥ 0,4 m zum Lager. Passt kein Platz, entfällt das Spielzeug. Reproduzierbar.

## 5. Ziele, HUD, Bedienung, Speichern
**Bonusziele** (`required: false`, je +2 Funkenstaub; Typ `spiel`)
| Id | Kap. | Ziel | Bedingung |
|---|---|---|---|
| T1 | 1 | „Fahr mit dem Auto unter das Bett“ | reitend auf Flitz innerhalb 0,15 m von (−1.50, 0, −1.00) |
| T2 | 1 | „Ringrennen“ | 3 Leuchtringe (Torus r 0,05) nacheinander mit Flitz: (−0.70, 0.03, −0.95) → (−1.45, 0.03, −1.25) → (−1.40, 0.03, −0.70), ab Ring 1 in ≤ 20 s; Bestzeit gemerkt |
| T3 | 2 | „Spring mit dem Pferd auf den Stuhl“ | reitend auf Hoppel landen mit y ≥ 0,47 innerhalb 0,25 m von (0.80, 0.47, −0.85) |
| T4 | 2 | „Lass den Bären zwei Wachen besiegen“ | 2 Abschüsse durch Watte |
| T5 | 3 | „Flieg mit dem Vogel aufs Regal“ | mit Flatter innerhalb 0,2 m von (1.86, 2.005, 0.15); Alternative zum Lampen-Aufwind |
| T6 | 3 | „Zähme den Dino“ | Knirsch besiegt |
- Scans: nur T4, T6 und „Wecke ein Spielzeug“.
- **HUD**: Funkenstaub-Zähler neben der Munition („Staub 3/9“). Hinweiszeile `#toy-prompt` über der Werkzeugleiste. Feder-Balken `#toy-energy` mit Namen, blinkt unter 5 s. Zielanzeige listet Bonusziele eingerückt; Zielpfeil per Tab auch auf gefundene Spielsachen. Boss-Balken oben Mitte, solange Knirsch wach ist.
- **Tastatur**: F Wecken / Auf- und Absteigen. Menü- und Pausentext ergänzen.
- **Touch**: Knopf `#t-toy`, nur sichtbar bei Hinweis oder beim Reiten („Wecken“ / „Absteigen“). Flitz: linker Stick = Gas/Lenken. Hoppel/Flatter: „Sprung“ halten = Laden bzw. Steigen.
- **Speichern** (bestehender Schlüssel, fehlendes Feld → Standardwerte): `toys: { found, tamed, staub, ring, freeUsed }`, Bonusziele in `done`.
- **Debug** (`?debug=1`): `wz.toys`, `wz.wake(id)`, `wz.staub(n)`, `wz.boss()`.

## 6. Bauliste
1. `TOYS`, `makeToyMesh`, `placeToys` (Demo), Schlaf-Animation, Aufräumen, Debug.
2. Funkenstaub, Hinweis, F/`#t-toy`, `wakeToy`/`sleepToy`, Feder-Balken, Herausschieben.
3. Reiten + Flitz. 4. Hoppel. 5. Flatter.
6. KI: Kantenprobe, Schnurr, Watte. 7. Knirsch-Boss und Zähmung.
8. Bonusziele T1–T6. 9. Speichern, Menütexte. 10. Foto-Raum und Scan-Platzierung. 11. Klänge, Feinschliff.

## 7. Prüfliste
- Demo: alle 6 bestehen den Freiraum-Test ohne Nachrücken; keines näher als 8 cm an einem Ziel.
- Wecken: erstes Flitz-Wecken gratis, zweites kostet 2; mit 0 Staub Fehlton; Flatter in Kapitel 1 nicht weckbar.
- Flitz: Messstrecke (1.20, 0, −0.05) → (−0.90, 0, −0.05): ≥ 2 m in ≤ 4 s; Tempo nie > 1,3 m/s; rollt über Teppichkante und Kabel.
- Kein Tunneln: je 20 Fahrten mit Schub gegen Wand, Bettbein und Schuhkarton bei 30 und 240 fps.
- T1/T2 auslösbar; Ringrennen in ≤ 20 s machbar; Ringe außer der Reihe zählen nicht.
- Hoppel: voller Ladesprung 0,50–0,60 m; von (0.95, 0, −0.50) Richtung −z Landung auf dem Stuhlsitz; Tipp-Sprung ≤ 0,10 m.
- Flatter: Tisch → Regaldach (y ≥ 2,005, T5) in ≤ 10 s; Feder leer → sichere Landung; nie über Deckel.
- Schnurr: bei N1 lassen in 3 s mindestens 2 Wachen ab; nach 15 s zurück.
- Watte: besiegt zwei Wachen in ≤ 15 s; fällt nicht von der Matratze; schläft bei 1,3 m Abstand nach 3 s ein.
- Knirsch: erwacht bei Nest-LP ≤ 4; bleibt ≤ 0,6 m vom Nest auf der Tischplatte; 30 Treffer besiegen ihn; danach gezähmt, T6; Spielertod setzt zurück.
- Reiten: Sicht nach Absteigen wiederhergestellt; Absteigen nie in Geometrie (50 Versuche); Haken/Gleiter beim Reiten gesperrt.
- Speichern: Flitz wecken, T1, neu laden → Fortschritt erhalten; blockiertes `localStorage` ohne Fehler.
- Foto-Raum/Scan: Spielsachen auf begehbaren Flächen, reproduzierbar; Platzierung < 30 ms.
- Touch: Wecken, Fahren, Springen, Fliegen, Absteigen per Knopf; 60 s ohne Konsolenfehler.
