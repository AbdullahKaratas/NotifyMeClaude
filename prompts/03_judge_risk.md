# SCHRITT 3: JUDGE & RISK

**Asset:** {{SYMBOL}}

---

**Input:** Daten aus Schritt 1 + Debate aus Schritt 2 + Chart

---

## INVESTMENT JUDGE

**Der Judge MUSS den Chart als unabhängige Quelle heranziehen!**

### JUDGE CHART-ANALYSE

**Analysiere den Chart UNABHÄNGIG von Bull/Bear:**

| Aspekt | Deine Beobachtung | Gewichtung |
|--------|-------------------|------------|
| Trend-Richtung | [Was siehst du?] | Hoch/Mittel/Niedrig |
| SMA-Konstellation | [Golden/Death Cross?] | Hoch/Mittel/Niedrig |
| RSI-Signal | [Überkauft/Überverkauft/Neutral?] | Hoch/Mittel/Niedrig |
| Volume-Bestätigung | [Bestätigt Volume den Trend?] | Hoch/Mittel/Niedrig |
| Money Flow (CMF) | [Akkumulation/Distribution?] | Hoch/Mittel/Niedrig |
| Chart-Pattern | [Erkennbare Muster?] | Hoch/Mittel/Niedrig |

**Chart-Urteil:** Der Chart spricht für [BULL/BEAR/NEUTRAL] weil [1-2 Sätze]

### URTEIL

Analysiere die Bull vs Bear Argumente aus Schritt 2:

**Bewertung der Argumente:**

| Seite | Stärke | Beste Argumente |
|-------|--------|-----------------|
| 🐂 Bull | X/10 | [Top 2 Argumente] |
| 🐻 Bear | X/10 | [Top 2 Argumente] |
| 📊 Chart | X/10 | [Was sagt der Chart?] |
| 🩳 Short Interest | X% Float / X Tage | [Squeeze-Potential oder bearishes Signal?] |

**Entscheidende Faktoren:**
1. [Wichtigster Faktor]
2. [Zweitwichtigster Faktor]
3. [Drittwichtigster Faktor]

### ENTSCHEIDUNG

```
╔═══════════════════════════════════════╗
║  SIGNAL: [LONG / SHORT / HOLD]        ║
║  KONFIDENZ: [XX]%                     ║
╚═══════════════════════════════════════╝
```

**Begründung:** [2-3 Sätze warum diese Entscheidung - inkl. Chart-Bestätigung!]

### Confidence Score Referenz:
| Wert | Bedeutung |
|------|-----------|
| 0.85-1.00 | Extrem stark - alle Signale aligned |
| 0.70-0.84 | Stark - klare Richtung |
| 0.55-0.69 | Moderat - einige Gegenfaktoren |
| 0.40-0.54 | Schwach - eher HOLD |
| < 0.40 | Unklar - HOLD oder IGNORE |

---

## KO-LEVEL ANALYSE

Basierend auf dem Signal: **[LONG/SHORT]**

```
╔═══════════════════════════════════════════════════════════════╗
║  KO-BERECHNUNG: ATR + CHART-SUPPORT KOMBINIERT               ║
╠═══════════════════════════════════════════════════════════════╣
║                                                               ║
║  SCHRITT A: ATR-Multiplikator nach Asset-Klasse bestimmen    ║
║  SCHRITT B: Chart-Support/Resistance identifizieren          ║
║  SCHRITT C: KO = das WEITER ENTFERNTE von beiden             ║
║                                                               ║
║  ❌ NIEMALS KO zwischen Preis und Support setzen!            ║
║  ❌ NIEMALS nur ATR ODER nur Chart nutzen - IMMER beides!    ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
```

### SCHRITT A: ATR-Multiplikator nach Asset-Klasse

ATR (14) aus Schritt 1: **$XX.XX (X.X%)**

| Asset-Klasse | Beispiele | ATR-Multiplikator | Warum |
|-------------|-----------|-------------------|-------|
| Large Cap Aktien | NVDA, AAPL, MSFT | 2.0x ATR | Stabile Orderbücher, geringe Gap-Gefahr |
| Mid/Small Cap Aktien | ARM, IREN, VST | 2.5x ATR | Dünnere Liquidität, stärkere Earnings-Moves |
| Rohstoffe (Gold, Silber) | GC=F, SI=F | 3.0x ATR | Makro-Schocks (Fed, Zölle, Geopolitik), Gap-Risiko über Nacht |
| Krypto-bezogen | MSTR, COIN | 3.0x ATR | Extreme Volatilität, 24/7 Underlying |
| Gehebelte Indizes | QQQ, SPY Turbos | 2.0x ATR | Breit diversifiziert, weniger Einzelrisiko |

**Bestimme die Asset-Klasse von {{SYMBOL}}:** [Klasse]
**ATR-Multiplikator:** [X.Xx]
**ATR-basiertes KO-Level (LONG):** Preis - (ATR x Multiplikator) = $XX.XX - ($XX.XX x X.X) = **$XX.XX**
**ATR-basiertes KO-Level (SHORT):** Preis + (ATR x Multiplikator) = $XX.XX + ($XX.XX x X.X) = **$XX.XX**

### SCHRITT B: Chart-Support als Mindestabstand

Identifiziere die relevanten Chart-Levels aus Schritt 1:

| Level | Preis | Stärke (1-5) | Begründung |
|-------|-------|--------------|------------|
| Nächster Support (S1) | $XX.XX | X/5 | [Warum ist das ein Support?] |
| Starker Support (S2) | $XX.XX | X/5 | [Warum?] |
| Kritischer Support (S3) | $XX.XX | X/5 | [Warum?] |

**Chart-basiertes KO-Level:** Unter dem stärksten relevanten Support + Puffer (0.5-1%)
→ Support bei $XX.XX → KO bei **$XX.XX** (Support - X%)

### SCHRITT C: FINALES KO-LEVEL

```
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║  REGEL: KO = das WEITER vom Preis ENTFERNTE Level            ║
║                                                               ║
║  ATR-basiert:    $XX.XX (XX.X% vom Preis)                    ║
║  Chart-basiert:  $XX.XX (XX.X% vom Preis)                    ║
║                                                               ║
║  → FINALES KO:  $XX.XX (XX.X% vom Preis)                    ║
║  → Hebel:       ~Xx                                          ║
║  → Methode:     [ATR / Chart / Beide gleich]                 ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
```

**Begründung:** [2-3 Sätze warum dieses KO-Level. Welches Chart-Level schützt? Warum reicht der ATR-Abstand (nicht)?]

### EARNINGS / EVENT-WARNUNG

```
⚠️ EARNINGS/EVENT CHECK:
- Nächster Earnings-Termin: [Datum oder "keiner in 2 Wochen"]
- Andere Events (Fed, CPI, etc.): [Datum]
- WENN Event < 5 Handelstage entfernt:
  → ATR-Multiplikator um +0.5 erhöhen (Earnings-Gaps!)
  → ODER Position vor Event teilweise schließen
```

---

## RISK-PER-TRADE CHECK

```
╔═══════════════════════════════════════════════════════════════╗
║  PORTFOLIO-SCHUTZ                                            ║
╠═══════════════════════════════════════════════════════════════╣
║                                                               ║
║  Portfolio-Wert (aus Supabase):     XXX EUR                  ║
║  Max. Verlust pro Trade (10%):      XXX EUR                  ║
║  Max. gleichzeitig riskiert (40%):  XXX EUR                  ║
║  Aktuell riskiert (offene Pos.):    XXX EUR                  ║
║  Noch verfügbares Risiko-Budget:    XXX EUR                  ║
║                                                               ║
║  ⚠️ Wenn Risiko-Budget aufgebraucht → KEIN neuer Trade!     ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
```

---

## TRADE-PLAN

**Basierend auf der Analyse - konkrete Handlungsempfehlung:**

### Entry
| Aktion | Preis | Begründung |
|--------|-------|------------|
| **Buy** | $XX.XX | [Warum hier einsteigen?] |
| **KO-Level** | $XX.XX | [ATR + Chart kombiniert] |

### Exits (gestaffelt)
| Aktion | Preis | Anteil | Begründung |
|--------|-------|--------|------------|
| **Sell** | $XX.XX | XX% | [Welches Resistance-Level?] |
| **Sell** | $XX.XX | XX% | [Nächstes Ziel?] |
| **Sell** | $XX.XX | Rest | [Stretch-Ziel?] |

### Stops
| Aktion | Preis | Anteil | Begründung |
|--------|-------|--------|------------|
| **Stop** | $XX.XX | XX% | [Mentaler Stop ÜBER KO!] |
| **Stop** | $XX.XX | Rest | [Absolutes Limit?] |

### Time-Stops
| Bedingung | Aktion |
|-----------|--------|
| Nach 5 Handelstagen <5% im Plus | Position halbieren |
| Nach 8 Handelstagen seitwärts | Position schließen |
| Earnings < 2 Tage entfernt | Min. 50% sichern |

### Watch Zones
| Zone | Preis-Range | Was tun? |
|------|-------------|----------|
| [Zone 1] | $XX - $XX | [Beobachten / Nachkaufen / Verkaufen?] |
| [Zone 2] | $XX - $XX | [Beobachten / Nachkaufen / Verkaufen?] |

---

## ENFORCEMENT

- ✅ Judge analysiert Chart UNABHÄNGIG von Bull/Bear
- ✅ Signal-Box mit LONG/SHORT/HOLD + Konfidenz%
- ✅ KO-Level mit BEIDEN Methoden berechnet (ATR + Chart)
- ✅ ATR-Multiplikator nach Asset-Klasse differenziert
- ✅ KO liegt IMMER unter dem stärksten Support (LONG) / über Resistance (SHORT)
- ✅ Earnings/Event-Warnung geprüft
- ✅ Risk-per-Trade Check gegen Portfolio-Limit
- ✅ Gestaffelter Sell-Plan mit konkreten Preisen und Prozenten
- ✅ Time-Stops definiert
- ✅ Stop-Levels basierend auf Support-Zonen

```
✅ [SCHRITT 3: JUDGE & RISK ABGESCHLOSSEN]
```
