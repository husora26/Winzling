# Winzling – Design-Spec „Schreibtisch-Set“ (Menü, UI-System, Avatar, Editor)

Grundlage: `index.html` (CSS Z. 5–288, HTML Z. 290–505, Figur Z. 3130–3208). Vor dem Umbau `showMenu()`, `die()` und den Menü-Kameraflug nachlesen.

## 0. Leitidee
Alles UI ist Schreibtischmaterial, das ein Riese liegen gelassen hat. Vier Materialien: **Papier** (Karten, Notizzettel), **Klebeband** (Tabs, Markierung „aktiv“), **Stempel** (Status, Erfolge, Primäraktion), **Maßband** (Fortschritt, Slider, Skalen). Bleistiftstriche sind die einzige Dekoration (Unterstreichung, Häkchen, Einkreisen). Im Spiel wird Papier zu dunklem „Pauspapier“ (bestehendes Glas).

## 1. Design-System
**Farb-Tokens** (bestehende Namen bleiben, neue in `:root`):
- `--ink #1d1a17`, `--ink-soft #5a5046`
- `--paper #fbf3dc`, `--paper-shade #efe3c0`, `--paper-line #d9c99a`
- `--pencil #f5b82e` (Fläche; Text darauf `--ink`), `--pencil-text #8a5a00` (ersetzt `--pencil-dark` überall, wo es Schrift ist)
- `--eraser #e86a6a`, `--eraser-text #a8322b`
- `--mint #5fc9a8`, `--mint-text #1c6f57`
- `--tape #cfe3ea` (85 % Deckkraft), `--stamp #2f5d73`
- `--glass`, `--glass-line`, `--text-on-glass`, `--muted-on-glass` unverändert (HUD).

**Schrift** (Google Fonts): `Bungee` nur für Titel, HUD-Zahlen, Stempel; `Rubik 400/500/700` für Lesbares; neu `Caveat 600` als Bleistiftschrift für Randnotizen, Maßangaben, Avatar-Name, nie unter 18 px. Skala: `--fs-xs 12`, `--fs-s 14`, `--fs-m 16` (auch Eingabefelder), `--fs-l 20`, `--fs-xl 28`, `--fs-title clamp(40px, 9vw, 72px)`.

**Abstände** `--s1 4 … --s6 32` (4/8/12/16/24/32). **Radien** `--r-paper 3px`, `--r-pill 999px`, `--r-glass 10px`. **Schatten** `--sh-lie 0 1px 0 rgba(0,0,0,.25), 0 6px 14px rgba(0,0,0,.28)`, `--sh-lift 0 2px 0 rgba(0,0,0,.25), 0 14px 28px rgba(0,0,0,.38)`, `--sh-press inset 0 2px 0 rgba(0,0,0,.2)`.

**Bewegung** `--t-fast 120ms`, `--t-med 220ms`, `--t-slow 420ms`, Kurve `cubic-bezier(.2,.8,.2,1)`. Drei Bewegungen: *Ablegen* (Karte mit 12 px Versatz und 2° Drehung zur Ruhe), *Stempeln* (Skalierung 1,25 → 1), *Abziehen* (Tab-Wechsel). `prefers-reduced-motion`: nur Deckkraft 120 ms, Kameraflug und Drehteller stehen.

**Fokus** `:focus-visible { outline: 3px solid var(--stamp); outline-offset: 3px }`, auf Glas `var(--pencil)`.

**Komponenten** (`.btn`, `.note`, `.overlay` bleiben, nur neu gestylt):
- `.btn` Sekundär: Papier, 2 px `--ink`-Rand, min. 48 px hoch, Rubik 700; Hover `--sh-lift` −1 px; aktiv `--sh-press`.
- `.btn.primary` Stempel: `--pencil`, Bungee, 56 px hoch, `border-radius: 14px 10px 13px 11px`.
- `.btn.danger`: Papier mit `--eraser-text` Rand/Schrift.
- `.btn.icon`: 48×48 rund, immer `aria-label`.
- `.card` (Weltkarten): Papier, `--sh-lie`, Vorschau 16:9 oben (prozedural/Canvas oder Screenshot der Szene), Titel + Zeile + Statusstempel; die ganze Karte ist ein `<button>`.
- `.tabs`/`.tab`: Klebebandstreifen, aktiv `--pencil`, inaktiv `--tape`; `role=tablist`, Pfeiltasten; Handy horizontal scrollbar mit scroll-snap.
- `.ruler`: `<input type=range>`, Spur als Maßband (`repeating-linear-gradient`), Daumen 28 px in 44 px Trefferfläche, Wert in Caveat.
- `.swatch`: 36 px in 44 px Trefferfläche, gewählt = Bleistiftkreis; `role=radio` in `radiogroup`, `aria-label` Farbname.
- `.toggle`: Kästchen mit Bleistift-Häkchen (echte Checkbox), 44 px Zeile.
- `.seg`: verbundene `.btn`, gewählt `--pencil`, `aria-pressed`.
- `.toast`: Haftnotiz (im Spiel Glas), `role=status`.
- `.modal`: zentrierte `.note`, max. 440 px, Fokusfalle, Esc schließt, Fokus zurück zum Auslöser. (Ersatz für confirm(), das im Sandbox-Frame nicht geht.)
- `.stamp`: gedrehtes Etikett (−4°), doppelter Rand in `--stamp` oder `--mint-text` („NEU“, „3/5 Kapitel“, „BEZWUNGEN“).

## 2. Hauptmenü
3D-Szene (vorhandener Flug auf 2 cm Höhe) bleibt vollflächig. Menü als **Schreibtischunterlage links** (Desktop 420 px Spalte, Rest freie Sicht; der eigene Winzling steht rechts unten im Bild und winkt). Verlauf von links `rgba(15,13,11,.75)` → 0.

**Bildschirme** (`ui.screen`, je ein `<section>` in `#menu`):
1. `start` – Titel, Primärknopf, vier Navigationszeilen.
2. `welten` – vier Weltkarten.
3. `avatar` – Editor.
4. `einstellungen` – Tabs Grafik / Ton / Steuerung.
5. `anleitung` – Tabs „Spielen“ (bisherige controls-list, Tastatur- oder Touch-Variante), „Eigenes Zimmer“ (bisheriges #howto), „Maßstab“.

**Start**: Titel „WINZLING“ (Bungee) mit Maßband-Strich darunter, Caveat „2 cm – das bist du“. Primärknopf: ohne Spielstand „Spielen“ (Demo), mit Spielstand „Weiter“ + Unterzeile „Demo-Zimmer · Kapitel 2 · 7/12 Splitter“ + Maßband-Fortschritt (aus `loadProgress`/`roomIdFor`). Liste: „Zimmer wählen“, „Winzling gestalten“ (mit Avatar-Name in Caveat), „Einstellungen“, „Anleitung“. „Neu beginnen“ wird `.btn.danger` auf der jeweiligen Weltkarte mit Bestätigungs-Modal.

**Welten** (Desktop 2×2, hochkant 1 Spalte, quer 4 nebeneinander horizontal scrollend): „Demo-Zimmer“ (#btn-demo, Stempel Fortschritt), „Mein Foto-Zimmer“ (#btn-foto-play; ohne Zimmer ausgegraut „Noch keins gebaut“, aria-disabled), „Kamera-Zimmer erstellen“ (#btn-foto), „Scan laden“ (#btn-load + #file-input; #load-error darunter, role=alert). Vorhandene Button-IDs bleiben.

**Einstellungen**: Grafik = `.seg` mit den bestehenden `data-gfx`-Knöpfen plus Erklärung. Ton = `.ruler` Lautstärke 0–100 (neuer Master-GainNode; alle Klänge inkl. Motor daran hängen) plus Stumm-Toggle. Steuerung = Mausempfindlichkeit 0,5–2,0× (Faktor auf 0.0022 in `look()`), Touch-Umsehen-Regler, Toggle „Y-Achse umkehren“, Ansicht Ego/Außen (`setView`). Speichern als JSON `winzling.settings` via `lsGet`/`lsSet`.

**Navigation**: Unterbildschirme mit `.btn.icon` „Zurück“ oben links und Überschrift. Esc und Browser-Zurück gehen eine Ebene hoch (history.pushState nur mit `#name`-Hashes oder ohne URL-Änderung, da der Frame nur einfache Hashes durchlässt; im Spiel bleibt Esc = Pause). Übergang: 120 ms ausblenden, „Ablegen“ einblenden; Fokus auf Überschrift. Kamera fährt beim Wechsel zu `avatar` in 600 ms zum Drehteller.

**Größen**: hochkant 390 px volle Breite, 16 px Rand, vertikal scrollend innerhalb #menu. Quer 844×390: zwei Spalten (links Titel + Primär ca. 300 px, rechts Liste), Titel 40 px; Safe-Area beachten.

**Weitere Bildschirme**:
- **Pause**: schmale Notiz, Primär „Weiterspielen“, 2×2 Sekundär (Zurück zum Lager, Ansicht wechseln, Einstellungen, Hauptmenü), „Neu beginnen“ als danger mit Bestätigung. Einstellungen = derselbe DOM-Abschnitt wie im Menü (umhängen); doppelte gfx-row entfällt.
- **Tod**: eigene Variante mit `--eraser`-Stempel „AUTSCH“, Primär „Am Lager aufwachen“, Sekundär „Hauptmenü“; nur die vorhandene Vignette.
- **Sieg** (#win): Stempel „BEZWUNGEN“ (Stempeln-Animation), #win-stats als Maßband-Zeilen, Avatar jubelt. Knöpfe unverändert.
- **Foto-Raum** (#foto): drei nummerierte Schritte („1 Größe“, „2 Fotos“, „3 Bauen“) auf einer scrollbaren Seite; Slots als `.card`-Kacheln mit Vorschau und Häkchen-Stempel; Datenschutzsatz nur einmal; Zahlenfelder 48 px hoch, 16 px Schrift; Löschen = danger.
- **Kalibrierung** (#calib): Seitenleiste (Desktop rechts 360 px) bzw. Blatt unten (max. 54vh), Maßband-Kopf mit #calib-dims, Drehknöpfe als `.btn.icon` mit Unterzeile, Checkboxen als `.toggle`; Inline-Styles in Klassen.

**HUD**: Positionen, Media-Queries und alle `#t-*`-Koordinaten bleiben unverändert. Nur Flächen: `.hud-box` Glas mit hellerer Oberkante und `--r-glass`; `#hp-bar`, `#toy-bar`, `#boss-track` als Maßbänder (Teilstriche alle 10 %); `.tbtn` 2 px Papierrand 35 %, aktiv `--pencil`; `#toast` Pauspapier mit Klebeband-Ecke. Größenänderung höchstens ±2 px.

## 3. Avatar-Aufwertung
**Schnittstelle bleibt**: `figure` (Group, Füße y=0, Blick −Z, rotation.order 'YXZ'), `fig.aim`, `fig.muzzle` (muzzleWorld und Seil hängen daran), `fig.legs`, `fig.armL`, `fig.umb`, `fig.glider`, `fig.phase`. Neu: `buildFigure(look)` → `{ root, joints, parts }`, benutzt für Spielfigur, Editor-Vorschau, Menüfigur; `applyLook(inst, look)` tauscht Farben und schaltet Varianten per `visible` (kein Neuaufbau pro Klick).

**Proportionen** (Höhe 2,0 cm, Augen 1,75 cm): Kopfhöhe 0,56 cm (ca. 3,5 Köpfe), kurzer Rumpf, kräftige Hände/Füße. Hüfte y 0,80 cm, Schulter 1,36 cm, Schulterbreite ±0,34 cm.

**Gelenke** (verschachtelte Groups): hips → spine → chest → neck → head; chest → shoulderL/R → elbowL/R → hand; hips → legL/R → kneeL/R → foot. Rumpf LatheGeometry (10 Profilpunkte, 12 Segmente); Glieder CapsuleGeometry (4/8); Kopf Kugel 16×12, y 0,95.

**Gesicht**: CanvasTexture 128×128 auf gewölbter Scheibe vor dem Kopf (transparent, depthWrite false): Augen, Brauen, Mund, Sommersprossen; Blinzeln alle 3–5 s für 120 ms (bei reduzierter Bewegung aus). Brille als Mesh (2 Torus + Steg). Ohren: zwei Kugeln.

**Haare** (6): `kurz` (Kugelkappe), `strubbel` (Kappe + 5 Kegel), `zopf` (Kappe + Tube hinten, pendelt), `locken` (7 Kugeln), `pilz` (Lathe-Topfschnitt), `muetze` (Lathe-Mütze mit Bommel in Haarfarbe).

**Kleidung** als Schichten: Oberteile `shirt`, `pulli`, `weste`, `kapuze`, `latz`. Hosen `lang`, `kurz` (Bein ab Knie Hautfarbe), `rock`, `pluder`. Schuhe `stiefel`, `sneaker`, `barfuss`.

**Ausrüstung** (sichtbar nur wenn freigeschaltet, im Editor immer): Rucksack `ranzen` (Box mit runder Klappe), `beutel` (Lathe-Sack), `nussschale` (Halbkugel); gefalteter Gleiter als gerolltes Blatt quer oben im Rucksack; beim Gleiten verschwindet die Rolle, `fig.glider` klappt in 180 ms auf. Gleitermuster `blatt`, `streifen`, `punkte` (Canvas-Textur). Enterhaken als gebogene Büroklammer (Tube) links am Gürtel + Seilrolle (Torus); unsichtbar, wenn der Haken fliegt. Löwenzahnschirm eingeklappt als Stiel rechts am Rucksack; offen mit 12 radialen Fäden (LineSegments).

**Budget** sichtbar < 5 000 Dreiecke; Geometrien teilen, Materialien pro Instanz.

**Animation** (Gelenkwinkel mit `1 − exp(−dt·12)` geblendet):
- `idle`: Atmen (Brust ±1,5 %, 0,4 Hz), Gewichtsverlagerung, gelegentliches Umsehen.
- `walk`/`run`: Beine ±0,7 / ±1,0 rad, Knie beugt in der Schwungphase, Rumpf beim Rennen 0,25 rad vor, Hüfte wippt, linker Arm schwingt, rechter Arm zielt (`fig.aim`).
- `jump`/`fall`: Knie angezogen bzw. gestreckt, linker Arm hoch.
- `schirm` (state.gliding): linker Arm hält Stiel, Beine baumeln 1,2 Hz.
- `glide` (glide.on): Körper −0,9 rad, Arme an den Flügeln, Rollen aus glide.roll.
- `hang` (hook fest): linker Arm zum Anker, Pendeln, Beine angewinkelt; hook fly = Wurfpose.
- `mantle`: Arme hoch → stützen → Knie hoch.
- `ride`: Sitzpose je Spielzeug (Auto sitzend, Pferd/Maus rittlings, Vogel liegend), Hände am Spielzeug.
- Zusätze: Rückstoß beim Schuss, Treffer-Zucken, `jubel` (Sieg), `winken` (Menü).

**Ego-Ansicht**: an `gun` zwei Unterarme mit Händen (rechts am Griff, links stützt); Ärmel in Oberteilfarbe (bei shirt/latz Haut), Hand Hautfarbe. Nachladen: linke Hand greift kurz nach unten; Haken fest: linker Arm Richtung Anker; Schirm: Stiel am oberen Bildrand. Hände nur bei `gun.visible`. Mündungsposition unverändert.

## 4. Editor „Winzling gestalten“
**Layout**: Desktop zwei Spalten (links Bühne: Winzling auf Radiergummi-Drehteller, Lineal „2,0 cm“; rechts Papierkarte mit Tabs). Hochkant: Bühne oben 38 %, Karte darunter scrollt. Quer 844×390: Bühne links 40 %, Karte rechts 60 %, Tabs als senkrechter Klebeband-Stapel.

**Bühne**: auf demselben Renderer (kein zweiter WebGL-Kontext). Dreht langsam selbst; Ziehen dreht, danach 3 s Pause; Zoom per Rad / zwei Finger zwischen „ganz“ und „Kopf“; Tabs Gesicht/Haare zoomen auf den Kopf. Tastatur: Pfeile drehen, +/− zoomen (`aria-label="Vorschau, mit Pfeiltasten drehen"`). Posen-Vorschau `.seg` „Stehen / Laufen / Gleiten“.

**Tabs**:
- **Körper**: Statur schmal/normal/kräftig (Breite 0,9/1/1,1; Höhe, Kollision, Augenhöhe bleiben), Kopf normal/groß, Hautton 8 Swatches (`#f6d7c0, #f0c8a0, #dfae84, #c68e62, #a9714a, #85553a, #5f3c2a, #6fbf8f` „Koboldgrün“) + Eigene (`<input type=color>`).
- **Gesicht**: Augen punkt/rund/mandel/verschlafen, Augenfarbe 6, Brauen gerade/bogen/streng, Mund laecheln/offen/neutral/schief, Toggles Sommersprossen, Brille, Wangenrot.
- **Haare**: 6 Stile als Kacheln mit Mini-Silhouette, 8 Farben + eigene.
- **Kleidung**: Oberteil 5, Hose 4, Schuhe 3 als Kacheln; je Teil 8 Swatches + `.ruler` Farbton 0–360 (Sättigung/Helligkeit fest je Teil).
- **Ausrüstung**: Rucksack 3 + Farbe, Schirmfarbe 6, Gleitermuster 3 + Farbe, Hakenfarbe stahl/kupfer/rot/mint.
Kopfzeile: Namensfeld (max. 16 Zeichen, Caveat, Platzhalter „Dein Winzling“), „Zufall“ (alles außer Name, Stempeln-Animation), „Zurücksetzen“ (Modal). Kein Speichern-Knopf: Änderungen wirken sofort, 300 ms verzögert gespeichert, Stempel „gespeichert“. Fehler: Toast „Aussehen gilt nur bis zum Schließen der Seite“.

**Datenmodell** (`winzling.avatar` via lsGet/lsSet):
```json
{ "v": 1, "name": "", "body": { "build": "normal", "head": "normal", "skin": "#f0c8a0" },
  "face": { "eyes": "rund", "eyeColor": "#2b2622", "brows": "bogen", "mouth": "laecheln", "freckles": false, "glasses": false, "blush": true },
  "hair": { "style": "strubbel", "color": "#2b2622" },
  "outfit": { "top": "shirt", "topColor": "#f5b82e", "bottom": "lang", "bottomColor": "#2f5d73", "shoes": "stiefel", "shoeColor": "#2b2622" },
  "gear": { "pack": "ranzen", "packColor": "#8a5a3a", "umbrella": "#f6f1de", "gliderPattern": "blatt", "gliderColor": "#a8d878", "hook": "stahl" } }
```
Defaults = heutige Figurfarben. `sanitizeLook(raw)`: JSON.parse in try/catch, Kopie der Defaults, nur gültige Felder übernehmen (Auswahl gegen Listen, Farben `/^#[0-9a-f]{6}$/i`, Booleans `=== true`, Name auf 16 Zeichen, Steuerzeichen raus, Ausgabe nur per textContent), unbekannte Schlüssel verwerfen, höheres `v` → Defaults. `applyLook` aktualisiert alle Instanzen (Spielfigur, Ego-Hände, Menüfigur).

## 5. Baureihenfolge
1. Tokens, Caveat-Schrift, `--pencil-dark` als Textfarbe ablösen, Fokusring, Reduced-Motion.
2. Komponenten-CSS, Inline-Styles in Klassen.
3. Menü in Bildschirme zerlegen (Zurück, History, Fokus); Button-IDs behalten.
4. Einstellungen: Master-Gain, Empfindlichkeit, `winzling.settings`; Pause nutzt denselben Abschnitt.
5. Pause, Tod, Sieg, Foto-Raum, Kalibrierung umstylen; HUD-Flächen.
6. `buildFigure` + `applyLook` + `sanitizeLook`; alte Figur ersetzen, `fig.*`-Schnittstelle prüfen.
7. Animationszustände in `updateFigure`; Ego-Hände an `gun`.
8. Editor, Menüfigur winkt.
9. Durchgang 390×844, 844×390, 1440×900; Dreiecke zählen; Kontrast messen.

## 6. Prüfliste
- 390×844 und 844×390: kein horizontales Scrollen in Start, Welten, Editor, Einstellungen, Anleitung, Pause, Sieg, Tod, Foto-Raum, Kalibrierung; nichts abgeschnitten.
- Alle Bedienelemente ≥ 44×44 px; Abstand ≥ 8 px.
- Textkontrast ≥ 4,5:1 (gemessen; Bungee-Titel ≥ 3:1).
- Nur Tastatur: alles erreichbar, Fokus sichtbar, Esc eine Ebene zurück, Modal hält Fokus, Tabs/Swatches mit Pfeiltasten.
- `prefers-reduced-motion` respektiert.
- Editor: jede Kategorie ändern, neu laden → identisch; Zufall 3×, Zurücksetzen → Defaults; kaputter Speicher → Defaults ohne Fehler; localStorage blockiert → läuft.
- Aussehen gleich in Außenansicht, Ego-Händen, Menü, Sieg.
- Figur < 5 000 Dreiecke bei teuerster Kombination.
- Animation ohne Sprung in allen Zuständen inkl. Reiten auf allen sechs Spielsachen, Tod, Sieg.
- Seil beginnt an der Schleuder in beiden Ansichten; Schüsse treffen wie zuvor.
- HUD: keine neuen Überlappungen mit `#t-*`-Knöpfen.
- Lautstärke 0 = still (auch Motor); Empfindlichkeit sofort wirksam, nach Neuladen erhalten.
- Konsole: 0 Fehler/neue Warnungen im ganzen Ablauf; Menü-Bildrate auf „Schnell“ nicht schlechter.
- Schriften nur von Google Fonts; Fallbacks brechen das Layout nicht.
