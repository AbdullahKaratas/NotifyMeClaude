---
name: analyse-stock
description: "Run full 4-step multi-agent trading analysis for a stock. Use when the user says 'Analysiere', 'Analyse', 'analyze', or asks for a trading analysis of any stock symbol."
argument-hint: "<SYMBOL> [LANGUAGE]"
---

# 4-Schritt Multi-Agent Trading Analyse fuer $ARGUMENTS

## QUALITAETS-ANFORDERUNGEN

- **KEIN Schritt darf uebersprungen werden**
- **yfinance IMMER zuerst** - keine Web-Suche fuer Preisdaten
- **Chart wird von JEDEM Schritt analysiert**
- **Jedes Argument: 4-6 Saetze mit konkreten Zahlen**
- **Sprache:** Deutsch (Standard). JSON-Keys Englisch.
- **Wenn du merkst dass du abkuerzt -> STOPP -> Mach es richtig!**

## ABLAUF

Fuehre die 4 Schritte **nacheinander** aus. Jeder Schritt baut auf den vorherigen auf.

### Schritt 1: Datensammlung
Lies und fuehre aus: `prompts/01_data_collection.md`
- Ersetze `{{SYMBOL}}` mit dem Stock-Symbol aus $ARGUMENTS
- yfinance Python-Script ausfuehren (PFLICHT!)
- Chart generieren und visuell analysieren (PFLICHT!)
- News via Web-Suche (mindestens 5 mit Datum)
- Makro-Faktoren (Fed, DXY, CPI, Geopolitik)
- Short Interest analysieren

### Schritt 2: Investment Debate
Lies und fuehre aus: `prompts/02_investment_debate.md`
- Input: Datenblock + Chart aus Schritt 1
- 2 vollstaendige Runden Bull vs Bear
- Konkrete Preisziele pro Seite

### Schritt 3: Judge, Risk & Positionierung
Lies und fuehre aus: `prompts/03_judge_risk.md`
- Judge bewertet UNABHAENGIG (inkl. Chart!)
- Signal + Konfidenz-Score
- 3-Schritt KO-Berechnung (ATR-Multiplikator nach Asset-Klasse + Chart-Support + weiter entferntes Level)
- Earnings/Event-Warnung
- Risk-per-Trade Check gegen Portfolio (10% max, 40% gleichzeitig)
- Trade-Plan: Entry/Exits/Stops/Time-Stops/Watch Zones

### Schritt 4: Zusammenfassung & Versand
Lies und fuehre aus: `prompts/04_summary_send.md`
- Trading Card erstellen
- Chart zu Supabase hochladen
- Analyse als Reminder in Supabase speichern
- Zusammenfassung via Telegram senden

## KONTEXT

Portfolio-Stand (offene/geschlossene Positionen, Cash) aus der Supabase `portfolio` Tabelle lesen.
Analysen stehen in `reminders`, Watchlist in `stocks`.
