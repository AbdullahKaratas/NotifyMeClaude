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
║  KNOCKOUT STRATEGIEN                                 ║
╠══════════════════════════════════════════════════════╣
║  Konservativ: $XX.XX (XX% | Xx ATR)                  ║
║  Moderat:     $XX.XX (XX% | Xx ATR)                  ║
║  Aggressiv:   $XX.XX (X%  | Xx ATR)                  ║
║  Stop-Loss:   $XX.XX (mental, XX% ueber KO)          ║
║                                                      ║
╠══════════════════════════════════════════════════════╣
║  POSITIONS-EMPFEHLUNG                                ║
╠══════════════════════════════════════════════════════╣
║  Lotto (50 EUR):     [JA/NEIN] - [Produkt + KO]     ║
║  Klein (150 EUR):    [JA/NEIN] - [Produkt + KO]     ║
║  Standard (300 EUR): [JA/NEIN] - [Produkt + KO]     ║
║  Ohne Hebel (200 EUR): [JA/NEIN] - [ETF/ETC/Aktie]  ║
║                                                      ║
╠══════════════════════════════════════════════════════╣
║  SUPPORT              │  RESISTANCE                  ║
╠══════════════════════════════════════════════════════╣
║  S1: $XX.XX           │  R1: $XX.XX                  ║
║  S2: $XX.XX           │  R2: $XX.XX                  ║
║  S3: $XX.XX           │  R3: $XX.XX                  ║
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

**6. FAZIT & HANDLUNGSEMPFEHLUNG (100-150 Wörter)**
- Klare Empfehlung: Was soll der Trader tun?
- Entry-Strategie
- Risk Management
- Zeithorizont

---

## CHART HOCHLADEN (PFLICHT!)

**Lies SUPABASE_URL und SUPABASE_ANON_KEY aus der `.env` Datei!**

**1. Chart zu Supabase Storage hochladen:**
```bash
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
- ✅ Schritt 1: yfinance Live-Daten + Chart-Analyse + News + Fundamentals
- ✅ Schritt 2: Investment Debate (Bull Runde 1+2, Bear Runde 1+2)
- ✅ Schritt 3: Investment Judge + Trade-Plan (Entry/Exits/Stops/Watch Zones)
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

## ENFORCEMENT

- ✅ Trading Card mit allen Key-Facts
- ✅ Minimum 500 Wörter in der Analyse
- ✅ ALLE vorherigen Schritte in der Description
- ✅ Chart-URL in image_url
- ✅ SQL INSERT ausführen

```
✅ [SCHRITT 4: ZUSAMMENFASSUNG & VERSAND ABGESCHLOSSEN]
🏁 [ANALYSE KOMPLETT]
```
