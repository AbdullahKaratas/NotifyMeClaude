# SCHRITT 4: ZUSAMMENFASSUNG & VERSAND

**Asset:** {{SYMBOL}}

---

**Input:** ALLE Outputs der vorherigen Schritte (Daten, Debate, Judge, Risk)

---

## TRADING CARD

```
╔══════════════════════════════════════════════════════╗
║  {{SYMBOL}} ANALYSE                                  ║
╠══════════════════════════════════════════════════════╣
║                                                      ║
║  Preis:     $XX.XX (EUR XX.XX)                       ║
║  Signal:    [LONG / SHORT / HOLD]                    ║
║  Konfidenz: XX%                                      ║
║  ATR:       X.X% ($XX.XX/Tag)                        ║
║                                                      ║
╠══════════════════════════════════════════════════════╣
║  KO-LEVEL (ATR + Chart kombiniert)                   ║
╠══════════════════════════════════════════════════════╣
║  ATR-basiert:   $XX.XX (Xx ATR, Asset-Klasse: XXX)   ║
║  Chart-basiert: $XX.XX (unter Support $XX.XX)        ║
║  → FINALES KO:  $XX.XX (XX.X% Abstand)              ║
║  → Hebel:       ~Xx                                  ║
║  Stop-Loss:     $XX.XX (mental, ueber KO)            ║
║                                                      ║
╠══════════════════════════════════════════════════════╣
║  POSITIONS-EMPFEHLUNG (% vom Portfolio)              ║
╠══════════════════════════════════════════════════════╣
║  Lotto (5%):       XXX EUR - [Produkt + KO]         ║
║  Klein (15%):      XXX EUR - [Produkt + KO]         ║
║  Standard (30%):   XXX EUR - [Produkt + KO]         ║
║  Ohne Hebel (20%): XXX EUR - [ETF/ETC/Aktie]        ║
║                                                      ║
║  Max. Verlust bei Stop: XXX EUR (XX% Portfolio)      ║
║                                                      ║
╠══════════════════════════════════════════════════════╣
║  EXITS (gestaffelt)                                  ║
╠══════════════════════════════════════════════════════╣
║  Sell 1: $XX.XX (XX%) - [Begruendung]               ║
║  Sell 2: $XX.XX (XX%) - [Begruendung]               ║
║  Sell 3: $XX.XX (Rest) - [Stretch-Ziel]             ║
║  Time-Stop: X Tage ohne Bewegung → halbieren        ║
║                                                      ║
╠══════════════════════════════════════════════════════╣
║  SUPPORT              │  RESISTANCE                  ║
╠══════════════════════════════════════════════════════╣
║  S1: $XX.XX           │  R1: $XX.XX                  ║
║  S2: $XX.XX           │  R2: $XX.XX                  ║
║  S3: $XX.XX           │  R3: $XX.XX                  ║
║                                                      ║
╠══════════════════════════════════════════════════════╣
║  RISIKO-CHECK                                        ║
╠══════════════════════════════════════════════════════╣
║  Sektor-Konzentration: XX% [Sektor]  [✅/⚠️]       ║
║  Offene Positionen gleiche Richtung: X  [✅/⚠️]    ║
║  Naechstes Event: [Event] am [Datum]  [✅/⚠️]      ║
║  Risk-Budget verbraucht: XX%  [✅/⚠️]               ║
║                                                      ║
╠══════════════════════════════════════════════════════╣
║  ZEITHORIZONTE                                       ║
╠══════════════════════════════════════════════════════╣
║  Kurzfristig:  [LONG/SHORT/HOLD]                     ║
║  Mittelfristig:[LONG/SHORT/HOLD]                     ║
║  Langfristig:  [LONG/SHORT/HOLD]                     ║
║                                                      ║
╚══════════════════════════════════════════════════════╝
```

---

## AUSFUEHRLICHE ANALYSE ({{LANGUAGE}}, 500-800 Woerter)

**PFLICHT! Minimum 500 Wörter!**

Schreibe eine vollständige Analyse mit folgender Struktur:

**1. EINLEITUNG (50-100 Wörter)**
- Aktueller Kontext: Was passiert gerade mit dem Asset?
- Warum ist jetzt ein wichtiger Zeitpunkt für eine Analyse?

**2. TECHNISCHE SITUATION (100-150 Wörter)**
- Beschreibe den aktuellen Chart-Zustand
- Wichtige Levels und was sie bedeuten
- Trend-Stärke und -Richtung
- **Referenziere deine Chart-Beobachtungen!**

**3. FUNDAMENTALE FAKTOREN (100-150 Wörter)**
- Was treibt das Asset fundamental?
- Supply/Demand Situation
- Relevante Makro-Faktoren

**4. NEWS & KATALYSATOREN (100-150 Wörter)**
- Die wichtigsten aktuellen News
- Kommende Events die den Preis bewegen könnten
- Sentiment-Einschätzung

**5. RISIKEN (50-100 Wörter)**
- Was könnte schiefgehen?
- Was würde die These invalidieren?
- **Korrelations-Risiko zu bestehenden Positionen!**

**6. FAZIT & HANDLUNGSEMPFEHLUNG (100-150 Wörter)**
- Klare Empfehlung: Was soll der Trader tun?
- Entry-Strategie
- Risk Management (max. Verlust in EUR und % vom Portfolio)
- Zeithorizont
- **Gewinne mitnehmen!** Gestaffelte Exits einhalten!

---

## CHART HOCHLADEN (PFLICHT!)

**Lies SUPABASE_URL und SUPABASE_ANON_KEY aus der `.env` Datei!**

**1. Chart zu Supabase Storage hochladen:**
```bash
source .env
curl -X POST "${SUPABASE_URL}/storage/v1/object/charts/{{SYMBOL}}_chart.png" \
  -H "Authorization: Bearer ${SUPABASE_ANON_KEY}" \
  -H "Content-Type: image/png" \
  -H "x-upsert: true" \
  --data-binary @${CHART_OUTPUT_DIR}/{{SYMBOL}}_chart.png
```

**2. Chart-URL:**
```
${SUPABASE_URL}/storage/v1/object/public/charts/{{SYMBOL}}_chart.png
```

---

## DATENBANK-EINTRAG

**Sende ALLES an die NotifyMe App!**

Die App hat Markdown-Support im Detail-Screen. Der User will die **VOLLSTÄNDIGE** Analyse unterwegs auf dem iPhone lesen.

**KEINE KURZFASSUNG! Sende ALLE Schritte:**
- ✅ Schritt 1: yfinance Live-Daten + Chart-Analyse + News + Fundamentals + Korrelation
- ✅ Schritt 2: Investment Debate (Bull Runde 1+2, Bear Runde 1+2) + SHORT-Bewertung
- ✅ Schritt 3: Investment Judge + KO-Berechnung (ATR + Chart) + Trade-Plan
- ✅ Schritt 4: Trading Card + Ausführliche Analyse

```sql
INSERT INTO reminders (title, description, image_url, due_at, is_done)
VALUES (
  '🎯 {{SYMBOL}} Multi-Agent Analyse',
  '[VOLLSTÄNDIGE ANALYSE - ALLE SCHRITTE MIT ALLEN DETAILS]',
  '${SUPABASE_URL}/storage/v1/object/public/charts/{{SYMBOL}}_chart.png',
  NOW(),
  false
);
```

**WICHTIG:**
- Die `description` muss die **KOMPLETTE** Analyse enthalten (kann sehr lang sein - das ist OK!)
- Die `image_url` enthält den Chart für visuelle Referenz in der App
- Der User will ALLES auf dem iPhone lesen können - keine Informationen auslassen!

---

## TELEGRAM VERSAND (PFLICHT!)

**Sende die Trading Card als Telegram-Nachricht:**

```bash
source .env
python send_telegram.py "$(cat <<'EOF'
🎯 {{SYMBOL}} ANALYSE

Signal: [LONG/SHORT/HOLD] | Konfidenz: XX%
Preis: $XX.XX | KO: $XX.XX (XX.X%)
Stop: $XX.XX | Hebel: ~Xx

Exits: $XX.XX (XX%) → $XX.XX (XX%) → $XX.XX (Rest)
Time-Stop: X Tage

⚠️ Risiko: Max. XXX EUR (XX% Portfolio)
📊 Sektor-Konz.: XX% [Sektor]

Volle Analyse in der App.
EOF
)"
```

**Wenn Chart vorhanden, auch als Foto senden:**
```bash
python -c "
from send_telegram import send_photo
send_photo('${CHART_OUTPUT_DIR}/{{SYMBOL}}_chart.png', '📊 {{SYMBOL}} Chart')
"
```

---

## ENFORCEMENT

- ✅ Trading Card mit allen Key-Facts inkl. KO-Methode und Risiko-Check
- ✅ Positions-Empfehlung in % vom Portfolio (nicht feste EUR-Betraege)
- ✅ Minimum 500 Woerter in der Analyse
- ✅ ALLE vorherigen Schritte in der Description
- ✅ Chart-URL in image_url
- ✅ SQL INSERT ausfuehren
- ✅ Telegram-Nachricht mit Trading Card senden (PFLICHT!)
- ✅ Chart als Telegram-Foto senden

```
✅ [SCHRITT 4: ZUSAMMENFASSUNG & VERSAND ABGESCHLOSSEN]
🏁 [ANALYSE KOMPLETT]
```
