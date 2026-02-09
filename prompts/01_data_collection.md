# SCHRITT 1: DATENSAMMLUNG

**Asset:** {{SYMBOL}}

---

## STOP! ENFORCEMENT CHECKLIST

```
╔═══════════════════════════════════════════════════════════════╗
║  BEVOR DU ANFÄNGST:                                          ║
╠═══════════════════════════════════════════════════════════════╣
║                                                               ║
║  ✅ YFINANCE ZUERST: Python-Script für Live-Daten (PFLICHT!) ║
║  ✅ CHART GENERIEREN: Visuell den Chart analysieren!         ║
║  ✅ ECHTE News: Mit Datum, Quelle und Link                   ║
║  ✅ Web-Suche: NUR für News und aktuelle Events              ║
║  ✅ KORRELATION: Bestehende Positionen pruefen!              ║
║                                                               ║
║  ❌ NICHT Web-Suche für Preisdaten nutzen (veraltet!)        ║
║  ❌ KEINE erfundenen Daten oder Schätzungen ohne Quelle      ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
```

---

## 1.0 LIVE-DATEN VIA YFINANCE (PFLICHT!)

**Führe IMMER zuerst dieses Python-Script aus:**

```python
import yfinance as yf
import pandas as pd

def calculate_rsi(data, periods=14):
    delta = data['Close'].diff()
    gain = (delta.where(delta > 0, 0)).rolling(window=periods).mean()
    loss = (-delta.where(delta < 0, 0)).rolling(window=periods).mean()
    rs = gain / loss
    return 100 - (100 / (1 + rs))

def calculate_macd(data):
    exp1 = data['Close'].ewm(span=12, adjust=False).mean()
    exp2 = data['Close'].ewm(span=26, adjust=False).mean()
    macd = exp1 - exp2
    signal = macd.ewm(span=9, adjust=False).mean()
    histogram = macd - signal
    return macd, signal, histogram

from datetime import datetime

# Hole Daten für {{SYMBOL}}
ticker = yf.Ticker("{{SYMBOL}}")
hist = ticker.history(period='3mo')
info = ticker.info

# Berechne Technicals
rsi = calculate_rsi(hist)
macd, signal, histogram = calculate_macd(hist)

# EXAKTER TIMESTAMP
now = datetime.utcnow()
last_trade = datetime.fromtimestamp(info.get('regularMarketTime', 0))
market_state = info.get('marketState', 'UNKNOWN')

print('=' * 50)
print('{{SYMBOL}} - LIVE DATEN')
print('=' * 50)
print(f'⏱️ Analyse-Zeit:      {now.strftime("%Y-%m-%d %H:%M:%S")} UTC')
print(f'⏱️ Letzter Trade:     {last_trade.strftime("%Y-%m-%d %H:%M:%S")}')
print(f'📍 Market State:      {market_state}')
print('=' * 50)
print()
print('📈 PREIS & PERFORMANCE')
print(f'  Aktueller Preis:    ${info.get("currentPrice", 0):.2f}')
print(f'  Tages-Hoch:         ${info.get("dayHigh", 0):.2f}')
print(f'  Tages-Tief:         ${info.get("dayLow", 0):.2f}')
print(f'  Previous Close:     ${info.get("previousClose", 0):.2f}')
print(f'  52W Hoch:           ${info.get("fiftyTwoWeekHigh", 0):.2f}')
print(f'  52W Tief:           ${info.get("fiftyTwoWeekLow", 0):.2f}')
print()
print('📊 MOVING AVERAGES')
print(f'  50-Day SMA:         ${info.get("fiftyDayAverage", 0):.2f}')
print(f'  200-Day SMA:        ${info.get("twoHundredDayAverage", 0):.2f}')
price = info.get('currentPrice', 0)
sma50 = info.get('fiftyDayAverage', 1)
sma200 = info.get('twoHundredDayAverage', 1)
print(f'  Preis vs 50 SMA:    {((price/sma50)-1)*100:.1f}%')
print(f'  Preis vs 200 SMA:   {((price/sma200)-1)*100:.1f}%')
print(f'  Golden Cross:       {"JA" if sma50 > sma200 else "NEIN"}')
print()
print('📉 TECHNISCHE INDIKATOREN')
current_rsi = rsi.iloc[-1]
current_macd = macd.iloc[-1]
current_signal = signal.iloc[-1]
current_hist = histogram.iloc[-1]
rsi_status = "ÜBERKAUFT" if current_rsi > 70 else "ÜBERVERKAUFT" if current_rsi < 30 else "Neutral"
print(f'  RSI (14):           {current_rsi:.1f} ({rsi_status})')
print(f'  MACD:               {current_macd:.2f}')
print(f'  MACD Signal:        {current_signal:.2f}')
print(f'  MACD Histogram:     {current_hist:.2f} ({"BULLISH" if current_hist > 0 else "BEARISH"})')
print()
print('🩳 SHORT INTEREST')
print(f'  Shares Short:       {info.get("sharesShort", 0):,}')
print(f'  Short % of Float:   {info.get("shortPercentOfFloat", 0)*100:.1f}%')
print(f'  Short Ratio (Days): {info.get("shortRatio", 0):.1f}')
print()
print('💰 BEWERTUNG')
print(f'  Market Cap:         ${info.get("marketCap", 0)/1e9:.1f}B')
print(f'  P/S Ratio:          {info.get("priceToSalesTrailing12Months", 0):.0f}x')
print(f'  P/B Ratio:          {info.get("priceToBook", 0):.1f}x')
print()
print('💵 CASH & SCHULDEN')
print(f'  Total Cash:         ${info.get("totalCash", 0)/1e6:.0f}M')
print(f'  Total Debt:         ${info.get("totalDebt", 0)/1e6:.0f}M')
print(f'  Free Cash Flow:     ${info.get("freeCashflow", 0)/1e6:.0f}M')
print()
print('🎯 ANALYST TARGETS')
print(f'  Target High:        ${info.get("targetHighPrice", 0):.0f}')
print(f'  Target Mean:        ${info.get("targetMeanPrice", 0):.0f}')
print(f'  Target Low:         ${info.get("targetLowPrice", 0):.0f}')
print(f'  Recommendation:     {info.get("recommendationKey", "N/A").upper()}')
print()
print('📐 VOLATILITAET')
atr_data = hist['High'] - hist['Low']
atr14 = atr_data.rolling(14).mean().iloc[-1]
atr_pct = (atr14 / price) * 100
ann_vol = hist['Close'].pct_change().std() * (252**0.5) * 100
beta = info.get('beta', 'N/A')
print(f'  ATR (14):           ${atr14:.2f} ({atr_pct:.1f}%)')
print(f'  Ann. Volatilitaet:  {ann_vol:.0f}%')
print(f'  Beta:               {beta}')
print()
print('⚠️ RISK SCORES')
print(f'  Overall Risk:       {info.get("overallRisk", "N/A")}/10')
print()

# EARNINGS-KALENDER
print('📅 EARNINGS & EVENTS')
try:
    cal = ticker.calendar
    if cal is not None and len(cal) > 0:
        print(f'  Naechste Earnings:  {cal}')
    else:
        print('  Naechste Earnings:  Keine Daten verfuegbar')
except:
    print('  Naechste Earnings:  Keine Daten verfuegbar')
```

**WICHTIG:**
- ❌ NIEMALS Web-Suche für Preisdaten nutzen - immer yfinance!
- ✅ Web-Suche NUR für News und aktuelle Events
- ✅ Die yfinance-Daten sind die WAHRHEIT - nutze sie!

---

## 1.1 CHART GENERIEREN & ANALYSIEREN (PFLICHT!)

**Führe diesen Befehl aus (nutze Pfade aus `.env`):**

```bash
source .env 2>/dev/null
VENV="${YFINANCE_VENV:-python3}"
SCRIPT="${CHART_SCRIPT:-scripts/generate_chart.py}"
OUTPUT="${CHART_OUTPUT_DIR:-charts}"
$VENV $SCRIPT {{SYMBOL}}
```

**Dann lies den Chart:**

```
Lies die Datei: ${CHART_OUTPUT_DIR}/{{SYMBOL}}_chart.png
```

### CHART-INHALTE (4 Panels)

| Panel | Inhalt | Farben |
|-------|--------|--------|
| 1 | Candlesticks + Moving Averages | SMA 50 = Orange, SMA 200 = Purple |
| 2 | RSI (14) | Gelb, Overbought 70 = Rot, Oversold 30 = Grün |
| 3 | Volume | Grün = Bullish, Rot = Bearish |
| 4 | Money Flow | CMF = Cyan, OBV = Magenta |

### INITIALE CHART-ANALYSE (PFLICHT-TABELLE)

Dokumentiere was du im Chart siehst:

| Aspekt | Beobachtung |
|--------|-------------|
| **Trend** | Aufwärts/Abwärts/Seitwärts |
| **SMA 50/200** | Golden Cross / Death Cross / Neutral |
| **RSI** | Überkauft (>70) / Überverkauft (<30) / Neutral |
| **Volume** | Steigend/Fallend bei Preisbewegung |
| **CMF** | Positiv (Akkumulation) / Negativ (Distribution) |
| **Pattern** | Double Top/Bottom, H&S, Triangle, etc. |
| **Support** | Sichtbare Support-Levels im Chart |
| **Resistance** | Sichtbare Resistance-Levels im Chart |

---

## 1.2 Preis & Markt

| Datenpunkt | Wert | Quelle |
|------------|------|--------|
| Aktueller Preis (USD) | $XX.XX | yfinance |
| EUR/USD Kurs | X.XXXX | [Quelle] |
| Preis in EUR | €XX.XX | Berechnet |
| Tagesveränderung | +/-X.XX% | yfinance |
| 52-Wochen Hoch | $XX.XX | yfinance |
| 52-Wochen Tief | $XX.XX | yfinance |
| Volumen | XXM | yfinance |

## 1.3 Technische Indikatoren

| Indikator | Wert | Signal | Quelle |
|-----------|------|--------|--------|
| RSI (14) | XX.X | Überkauft/Neutral/Überverkauft | yfinance |
| MACD | X.XX | Bullish/Bearish Crossover | yfinance |
| SMA 50 | $XX.XX | Preis darüber/darunter | yfinance |
| SMA 200 | $XX.XX | Preis darüber/darunter | yfinance |
| Golden/Death Cross | Ja/Nein | Datum des letzten | yfinance |

## 1.4 Support & Resistance

| Level | Preis | Typ | Begründung |
|-------|-------|-----|------------|
| R3 | $XX.XX | Resistance | [Warum dieses Level?] |
| R2 | $XX.XX | Resistance | [Warum?] |
| R1 | $XX.XX | Resistance | [Warum?] |
| **Aktuell** | **$XX.XX** | — | — |
| S1 | $XX.XX | Support | [Warum?] |
| S2 | $XX.XX | Support | [Warum?] |
| S3 | $XX.XX | Support | [Warum?] |

## 1.5 Short Interest

| Datenpunkt | Wert | Bedeutung |
|------------|------|-----------|
| Short % of Float | XX.X% | Anteil der geshorteten Aktien |
| Short Ratio (Days to Cover) | X.X | Tage um alle Shorts zu covern |

**Short-Interest-Einordnung:**
- < 5%: Normal, kein besonderes Signal
- 5-10%: Erhoehte Skepsis, beobachten
- 10-20%: Hohes Short Interest, Short-Squeeze-Potential bei positiven Katalysatoren
- \> 20%: Extrem hoch, starkes Squeeze-Potential ABER auch starke bearishe Ueberzeugung
- Short Ratio > 5 Tage: Shorts koennen nicht schnell covern -> Squeeze-Risiko steigt

> **Hoher Short Interest ist KEIN automatisches Kaufsignal!** Er zeigt Skepsis, kann aber bei Katalysatoren (Earnings Beat, News) explosive Moves ausloesen.

---

## 1.6 Volatilitaet & Risiko-Profil

| Datenpunkt | Wert | Bedeutung |
|------------|------|-----------|
| ATR (14) | $XX.XX (X.X%) | Durchschnittliche Tagesschwankung |
| Ann. Volatilitaet | XX% | Jahres-Volatilitaet |
| Beta | X.XX | Markt-Sensitivitaet |

ATR wird in Schritt 3 fuer die KO-Berechnung genutzt. Hier nur den Wert dokumentieren.

**Volatilitaets-Einordnung:**

| ATR % | Einordnung | Bedeutung fuer Turbos |
|-------|------------|----------------------|
| < 2% | Niedrig | Enger KO moeglich, aber wenig Bewegung |
| 2-4% | Mittel | Standard-Turbos gut geeignet |
| 4-7% | Hoch | Weiter KO noetig, hoeheres Risiko |
| > 7% | Sehr hoch | Nur mit kleiner Position, weiter KO PFLICHT |

---

## 1.7 News & Katalysatoren

**Suche ECHTE NEWS! Nutze Web-Suche für aktuelle Headlines!**

Suchquellen:
- **Google News** - `{{SYMBOL}} news today`
- **Reuters** - `site:reuters.com {{SYMBOL}}`
- **Bloomberg** - `site:bloomberg.com {{SYMBOL}}`
- **Seeking Alpha** - `site:seekingalpha.com {{SYMBOL}}`
- **Kitco** (Commodities) - `site:kitco.com`
- **Oil Price** (Öl) - `site:oilprice.com`

**Mindestens 5 News-Items mit EXAKTEM TIMESTAMP:**

| # | Datum & Uhrzeit (UTC) | Headline | Impact | Quelle | Link |
|---|----------------------|----------|--------|--------|------|
| 1 | DD.MM HH:MM | [Vollständige Headline] | 🟢 Bullish / 🔴 Bearish / 🟡 Neutral | [Quelle] | [URL] |
| 2 | DD.MM HH:MM | [Vollständige Headline] | 🟢/🔴/🟡 | [Quelle] | [URL] |
| 3 | DD.MM HH:MM | [Vollständige Headline] | 🟢/🔴/🟡 | [Quelle] | [URL] |
| 4 | DD.MM HH:MM | [Vollständige Headline] | 🟢/🔴/🟡 | [Quelle] | [URL] |
| 5 | DD.MM HH:MM | [Vollständige Headline] | 🟢/🔴/🟡 | [Quelle] | [URL] |

**Für jede News: 1-2 Sätze Erklärung warum Bullish/Bearish:**
- News 1: [Erklärung]
- News 2: [Erklärung]
- News 3: [Erklärung]
- News 4: [Erklärung]
- News 5: [Erklärung]

## 1.8 Makro-Faktoren

**Aktuelle Werte via Web-Suche:**
- Fed/Zinsen: [Aktueller Stand + nächstes Meeting Datum]
- USD (DXY): [Aktueller Wert] + [Trend: steigend/fallend]
- Inflation: [Letzter CPI Wert + Datum]
- Treasury 10Y: [Aktueller Yield]
- Geopolitik: [Aktuelle Konflikte/Events die relevant sind]

## 1.9 Fundamentaldaten

| Faktor | Status | Details |
|--------|--------|---------|
| Angebot/Nachfrage | [Defizit/Überschuss] | [Details] |
| ETF Flows | [Inflow/Outflow] | [Zahlen wenn verfügbar] |
| COT Daten | [Commercials Long/Short] | [Quelle] |
| Saisonalität | [Bullish/Bearish Monat?] | [Historisch] |

---

## 1.10 KORRELATIONS-CHECK (PFLICHT!)

```
╔═══════════════════════════════════════════════════════════════╗
║  BEVOR ein neuer Trade eroeffnet wird:                       ║
║  Pruefe Korrelation zu bestehenden Positionen!               ║
║                                                               ║
║  → Lies offene Positionen aus Supabase `portfolio` Tabelle   ║
║  → Bestimme Sektor-Konzentration                             ║
║  → Wenn >60% in einem Sektor: WARNUNG ausgeben!              ║
╚═══════════════════════════════════════════════════════════════╝
```

**Bestehende offene Positionen (aus Supabase):**

| Symbol | Sektor | Richtung | Groesse (EUR) |
|--------|--------|----------|---------------|
| [aus DB] | [Sektor] | LONG/SHORT | XXX EUR |
| [aus DB] | [Sektor] | LONG/SHORT | XXX EUR |

**Korrelations-Bewertung:**

| Pruefung | Ergebnis | Status |
|----------|----------|--------|
| Gleicher Sektor wie {{SYMBOL}}? | [Ja/Nein - welche?] | ✅/⚠️ |
| Gleiche Richtung (alle LONG)? | [Ja/Nein] | ✅/⚠️ |
| Sektor-Konzentration | XX% in [Sektor] | ✅ <60% / ⚠️ >60% |
| Korreliert mit Nasdaq/S&P? | [Hoch/Mittel/Niedrig] | ✅/⚠️ |

**Wenn ⚠️ WARNUNG:**
> Hohe Korrelation erkannt! Bei einem Nasdaq-Einbruch von 3% wuerden ALLE Positionen gleichzeitig bluten. Erwaege: kleinere Positionsgroesse, SHORT-Hedge, oder unkorrelierten Trade (Gold, Short-Turbo auf Index).

---

## 1.11 EVENT-KALENDER

**Kommende Events die {{SYMBOL}} bewegen koennten:**

| Datum | Event | Erwarteter Impact | Relevanz |
|-------|-------|-------------------|----------|
| [Datum] | Earnings {{SYMBOL}} | 🔴🔴🔴 Hoch | Direkt |
| [Datum] | Fed Meeting / FOMC | 🔴🔴 Mittel-Hoch | Makro |
| [Datum] | CPI-Daten | 🔴 Mittel | Makro |
| [Datum] | Earnings [Peer] | 🟡 Niedrig-Mittel | Sektor |
| [Datum] | [Anderes Event] | [Impact] | [Relevanz] |

**⚠️ EARNINGS-WARNUNG:** Wenn {{SYMBOL}} Earnings < 5 Handelstage entfernt sind, wird dies in Schritt 3 bei der KO-Berechnung beruecksichtigt (erhoehter ATR-Multiplikator).

---

## ENFORCEMENT

- ✅ yfinance IMMER zuerst ausfuehren
- ✅ Chart generieren und visuell analysieren
- ✅ Chart-Analyse-Tabelle ist PFLICHT
- ✅ Keine Web-Suche fuer Preisdaten
- ✅ Jeder Datenpunkt mit Quelle
- ✅ Mindestens 5 News-Headlines mit Datum
- ✅ Korrelations-Check gegen bestehende Positionen (PFLICHT!)
- ✅ Event-Kalender mit Earnings und Makro-Terminen

```
✅ [SCHRITT 1: DATENSAMMLUNG ABGESCHLOSSEN]
```
