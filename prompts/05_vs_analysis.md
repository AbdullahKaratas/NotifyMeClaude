# VS-ANALYSE: {{SYMBOL_A}} vs {{SYMBOL_B}}

---

## ABLAUF

Führe die **vollständige Multi-Agent Analyse aus `prompts/00_master.md`** für BEIDE Assets durch, dann eine finale VS-Entscheidung.

**Jedes Asset durchläuft ALLE 4 Schritte des Master-Prompts:**

### Für {{SYMBOL_A}} UND {{SYMBOL_B}} jeweils:

```
Schritt 1: prompts/01_data_collection.md  → yfinance, Chart, News, Makro, Fundamentals
Schritt 2: prompts/02_investment_debate.md → Bull vs Bear, 2 vollständige Runden
Schritt 3: prompts/03_judge_risk.md       → Judge Signal + 3 KO-Strategien
```

**Es gelten ALLE Regeln aus `prompts/00_master.md`:**
- yfinance IMMER zuerst
- Chart wird von JEDEM Agenten analysiert
- Jedes Argument: 4-6 Sätze mit konkreten Zahlen
- Kein Schritt darf übersprungen werden!

---

## WICHTIG: LONG UND SHORT SIND GLEICHWERTIG!

Das Signal pro Asset kann **LONG, SHORT oder HOLD** sein. Die Analyse muss objektiv entscheiden:

- Asset A kann LONG sein, Asset B kann SHORT sein
- **Ein SHORT-Signal kann attraktiver sein als ein LONG-Signal!**
- Der Judge entscheidet pro Asset unabhängig die Richtung
- Die KO-Strategien werden passend zur Richtung berechnet:
  - **LONG:** KO-Level UNTER aktuellem Preis
  - **SHORT:** KO-Level ÜBER aktuellem Preis

**Beispiel:** Wenn Asset A ein schwaches LONG (52%) hat und Asset B ein starkes SHORT (72%), dann ist B der bessere Trade - als SHORT-Position!

---

## SCHRITT 4: VS-ENTSCHEIDUNG

**Erst NACHDEM beide Assets die vollständige Analyse (Schritte 1-3) durchlaufen haben!**

### 4.1 Daten-Vergleichstabelle

| Datenpunkt | {{SYMBOL_A}} | {{SYMBOL_B}} |
|---|---|---|
| Preis | | |
| ATH-Abstand | | |
| **Signal (LONG/SHORT/HOLD)** | | |
| **Konfidenz** | | |
| RSI | | |
| MACD | | |
| Golden Cross | | |
| Market Cap | | |
| Revenue | | |
| Revenue Growth | | |
| P/S Ratio | | |
| Gross Margin | | |
| Op Margin | | |
| EPS | | |
| Cash | | |
| Debt | | |
| FCF | | |
| Short % Float | | |
| Analyst Rating + Target | | |
| Risk Score | | |

### 4.2 Dimensionen-Vergleich

Bewerte jede Dimension und vergib einen Gewinner.
**Beachte:** "Gewinner" heißt das BESSERE Trade-Setup, egal ob LONG oder SHORT!

| Dimension | {{SYMBOL_A}} | {{SYMBOL_B}} | Gewinner |
|---|---|---|---|
| **Momentum** | [MACD, RSI, Trend] | | |
| **Chart-Setup** | [Pattern, SMA-Lage] | | |
| **Fundamentals** | [Revenue, Margins, Growth] | | |
| **Bewertung** | [P/S, P/B, Analyst Targets] | | |
| **Bilanz** | [Cash, Debt, FCF] | | |
| **Short Squeeze / Short Opportunity** | [Short %, Ratio] | | |
| **Potenzial in Signal-Richtung** | [Kursziel %] | | |
| **Risiko gegen Signal-Richtung** | [Gegensziel %] | | |
| **Risk/Reward** | [EV-Berechnung] | | |
| **Katalysatoren** | [Kommende Events] | | |

**Score: {{SYMBOL_A}} X - {{SYMBOL_B}} Y**

### 4.3 Risiko-Profil-Empfehlung

Gib für JEDES Profil eine separate Empfehlung.
**Die Empfehlung MUSS die Richtung (LONG/SHORT) enthalten!**

| Profil | Asset | Richtung | Warum |
|---|---|---|---|
| **Aggressiv** | [A oder B] | [LONG/SHORT] | [Begründung] |
| **Moderat** | [A oder B] | [LONG/SHORT] | [Begründung] |
| **Konservativ** | [A oder B] | [LONG/SHORT] | [Begründung] |

**WICHTIG:**
- Nicht pauschal einen Gewinner bestimmen - der hängt vom Risikoprofil ab!
- LONG ist NICHT automatisch besser als SHORT!
- Eine SHORT-Position mit hoher Konfidenz schlägt eine LONG-Position mit niedriger Konfidenz!

### 4.4 VS-Trading-Card

```
╔══════════════════════════════════════════════════════╗
║  ⚔️ VS-ANALYSE: {{SYMBOL_A}} vs {{SYMBOL_B}}         ║
╠══════════════════════════════════════════════════════╣
║                                                      ║
║  {{SYMBOL_A}}:                                       ║
║  Signal: [🟢 LONG / 🔴 SHORT / 🟡 HOLD] | XX%       ║
║  Preis: $XX | Kursziel: $XX (+/-XX%)                 ║
║  KO (Agg/Mod/Kons): $XX / $XX / $XX                 ║
║                                                      ║
║  {{SYMBOL_B}}:                                       ║
║  Signal: [🟢 LONG / 🔴 SHORT / 🟡 HOLD] | XX%       ║
║  Preis: $XX | Kursziel: $XX (+/-XX%)                 ║
║  KO (Agg/Mod/Kons): $XX / $XX / $XX                 ║
║                                                      ║
╠══════════════════════════════════════════════════════╣
║  🏆 GEWINNER PRO PROFIL:                             ║
║  Aggressiv:    [A/B] [LONG/SHORT] - [1 Satz]        ║
║  Moderat:      [A/B] [LONG/SHORT] - [1 Satz]        ║
║  Konservativ:  [A/B] [LONG/SHORT] - [1 Satz]        ║
╚══════════════════════════════════════════════════════╝
```

---

## SCHRITT 5: VERSAND

Führe `prompts/04_summary_send.md` aus:

- Sende die VS-Analyse an die NotifyMe App
- Inkludiere BEIDE vollständigen Analysen + VS-Entscheidung
- Chart des Gesamtgewinners als image_url

---

## REGELN

- **BEIDE Assets durchlaufen den VOLLSTÄNDIGEN Master-Prompt (00_master.md, Schritte 1-3)**
- **LONG und SHORT sind gleichwertig** - die beste Richtung pro Asset wird objektiv bestimmt
- **Der Gewinner hängt vom Risikoprofil ab** - nicht pauschal entscheiden!
- **Ein SHORT-Trade kann der attraktivere Trade sein!**
- **Jedes Argument: 4-6 Sätze mit konkreten Zahlen**
- **Charts für BEIDE Assets generieren und analysieren**
- **Sprache:** Deutsch (außer JSON-Keys)
- **Wenn du merkst dass du abkürzt → STOPP → Mach es richtig!**
