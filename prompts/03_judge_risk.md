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

## RISK DEBATE

**Knockout-Levels fuer die Signal-Richtung!**

**Alle 3 Analysten MUESSEN den Chart UND die ATR fuer ihre KO-Levels nutzen!**

Basierend auf dem Signal: **[LONG/SHORT]**

### Knockout Berechnung:
- **LONG:** KO-Level UNTER aktuellem Preis
- **SHORT:** KO-Level UEBER aktuellem Preis
- **Formel:** `distance_pct = |preis - ko_level| / preis * 100`

### ATR-Regel fuer KO-Planung:
```
╔═══════════════════════════════════════════════════════════════╗
║  ATR ist KEIN Ausschlusskriterium!                           ║
║  ATR bestimmt den MINDEST-ABSTAND des KO vom Preis.         ║
║                                                               ║
║  Faustregel: KO-Abstand >= 3x ATR (taegliche Schwankung)    ║
║                                                               ║
║  ATR 2% → KO mind. 6% Abstand                               ║
║  ATR 5% → KO mind. 15% Abstand                              ║
║  ATR 8% → KO mind. 24% Abstand                              ║
║                                                               ║
║  Hohe ATR = WEITERER KO, nicht "kein Trade"!                 ║
╚═══════════════════════════════════════════════════════════════╝
```

---

### RISKY ANALYST (Aggressiv)

**Chart-Analyse fuer KO-Level:**
> [Welches nahe Support/Resistance-Level siehst du im Chart?]

**KO-Level:** $XX.XX
**Abstand:** X.X% vom aktuellen Preis
**Hebel:** ~Xx
**Risiko:** HOCH
**ATR-Check:** Abstand = X.Xx ATR (mind. 2x noetig)

> Begruendung: [Warum dieses Level? Referenziere Chart-Levels!]

### SAFE ANALYST (Konservativ)

**Chart-Analyse fuer KO-Level:**
> [Welches weite Support/Resistance-Level siehst du im Chart?]

**KO-Level:** $XX.XX
**Abstand:** XX.X% vom aktuellen Preis
**Hebel:** ~Xx
**Risiko:** NIEDRIG
**ATR-Check:** Abstand = X.Xx ATR (mind. 3x empfohlen)

> Begruendung: [Warum dieses Level? Referenziere Chart-Levels!]

### NEUTRAL ANALYST (Moderat)

**Chart-Analyse fuer KO-Level:**
> [Welches moderate Support/Resistance-Level siehst du im Chart?]

**KO-Level:** $XX.XX
**Abstand:** XX.X% vom aktuellen Preis
**Hebel:** ~Xx
**Risiko:** MITTEL
**ATR-Check:** Abstand = X.Xx ATR (mind. 2.5x empfohlen)

> Begruendung: [Warum dieses Level? Referenziere Chart-Levels!]

---

## POSITIONS-STRATEGIE

**PFLICHT! Gib fuer JEDE Positionsgroesse eine konkrete Empfehlung:**

### Positionsgroessen-Matrix

| Groesse | Budget | Wann? | Empfohlenes Produkt | KO-Profil |
|---------|--------|-------|---------------------|-----------|
| **Lotto** | 50 EUR | Konfidenz < 55% ODER ATR > 8% | Turbo (weiter KO) | Konservativ |
| **Klein** | 100-150 EUR | Konfidenz 55-65% | Turbo (moderat KO) | Moderat |
| **Standard** | 200-300 EUR | Konfidenz > 65% UND ATR < 5% | Turbo (alle KOs) | Frei waehlbar |
| **ETF/ETC** | 200-300 EUR | ATR > 5% UND laengerer Horizont | ETF/ETC ohne Hebel | Kein KO |

### Konkrete Empfehlung:

**Fuer diesen Trade:**

| Szenario | Position | Produkt | KO/Stop | Erwarteter Gewinn | Max. Verlust |
|----------|----------|---------|---------|--------------------|--------------|
| Lotto (50 EUR) | [JA/NEIN] | [Turbo KO $XX] | Stop $XX | +XX EUR bei Ziel | -50 EUR |
| Klein (150 EUR) | [JA/NEIN] | [Turbo KO $XX] | Stop $XX | +XX EUR bei Ziel | -XX EUR |
| Standard (300 EUR) | [JA/NEIN] | [Turbo KO $XX] | Stop $XX | +XX EUR bei Ziel | -XX EUR |
| Ohne Hebel (200 EUR) | [JA/NEIN] | [ETF/ETC/Aktie] | Stop $XX | +XX EUR bei Ziel | -XX EUR |

> **Entscheide PRO Szenario** ob es sich lohnt. Ein Trade kann als "Lotto 50 EUR" Sinn machen, aber als "Standard 300 EUR" nicht!

### Stop-Loss Strategie

| Level | Preis | Typ | Aktion |
|-------|-------|-----|--------|
| **Mentaler Stop** | $XX.XX | Verkaufen bei Unterschreitung | Position schliessen |
| **KO-Level** | $XX.XX | Automatischer Totalverlust | Kein Handeln noetig |
| **Abstand Stop → KO** | XX% | Puffer zwischen Stop und KO | Je groesser desto besser |

> Der mentale Stop sollte IMMER deutlich UEBER dem KO liegen. So begrenzt du Verluste auf z.B. -30% statt auf -100%.

---

## ENFORCEMENT

- ✅ Judge analysiert Chart UNABHAENGIG von Bull/Bear
- ✅ Signal-Box mit LONG/SHORT/HOLD + Konfidenz%
- ✅ Alle KO-Levels mit Chart-Referenz, Abstand% UND ATR-Check
- ✅ 3 verschiedene Risiko-Profile (Aggressiv, Konservativ, Moderat)
- ✅ Jedes KO-Level mit Begruendung warum genau dieses Level
- ✅ Positions-Matrix mit 4 Szenarien (Lotto/Klein/Standard/Ohne Hebel)
- ✅ Stop-Loss Strategie mit mentalem Stop UEBER dem KO
- ✅ ATR wird als INPUT fuer KO-Abstand genutzt, NICHT als Ausschlusskriterium

```
✅ [SCHRITT 3: JUDGE & RISK ABGESCHLOSSEN]
```
