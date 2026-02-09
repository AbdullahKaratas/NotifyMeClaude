# Silver Hawk Trading

AI-powered trading analysis and price alerts via Telegram. Built with Claude Code, yfinance, and Supabase.

## What It Does

- **Multi-Agent Analysis:** 4-step pipeline (data collection, bull/bear debate, judge verdict, trading card) for any stock or commodity
- **Automatic Price Updates:** GitHub Actions updates your watchlist every 30 min
- **Price Alerts:** Telegram notifications on big moves, level crossings, and flash spikes
- **Position Sizing:** ATR-based knockout levels with 4 position size scenarios
- **Short Interest Tracking:** Squeeze potential and bearish sentiment analysis

## Quick Start

```bash
# Install Claude Code
npm install -g @anthropic-ai/claude-code

# Clone and configure
git clone https://github.com/YOUR_USERNAME/NotifyMeClaude.git
cd NotifyMeClaude
cp .env.template .env    # Fill in your credentials

# Install dependencies and seed watchlist
pip3 install yfinance numpy
python3 admin_stocks.py seed

# Run your first analysis
claude
> Analysiere AAPL @prompts/00_master.md
```

Full setup guide: **[ONBOARDING.md](ONBOARDING.md)** (DE) | **[ONBOARDING_EN.md](ONBOARDING_EN.md)** (EN)

## Requirements

- **Claude Pro** ($20/month) - for Claude Code
- **Telegram** (free) - create a bot via @BotFather
- **Supabase** (free tier) - database and storage
- **GitHub Actions** (free) - automated price updates

## Architecture

```
You (Claude Code)
├── Analysiere AAPL @prompts/00_master.md    → 4-step analysis → Telegram
├── python3 browse_stocks.py                  → View watchlist
└── python3 admin_stocks.py add TSLA ...      → Manage watchlist

GitHub Actions (automatic)
├── update_stocks.yml (every 30 min)          → Update prices, RSI, SMAs
└── tracker.yml (every 10 min)                → Price alerts → Telegram

Supabase (your own instance)
├── stocks table                              → Watchlist with live data
├── reminders table                           → Analysis results
├── tracker_state table                       → Alert state persistence
└── charts/ bucket                            → Chart images
```

## Analysis Pipeline

```
Analysiere NVDA @prompts/00_master.md
```

| Step | What Happens |
|------|-------------|
| 1. Data Collection | yfinance prices, RSI, MACD, SMAs, ATR, short interest, news |
| 2. Investment Debate | Bull vs Bear - 2 rounds with concrete arguments |
| 3. Judge & Risk | Verdict + confidence %, 3 KO strategies, position sizing matrix |
| 4. Trading Card | Summary card + full analysis sent to Telegram + Supabase |

## Scripts

| Script | Purpose |
|--------|---------|
| `browse_stocks.py` | View watchlist with prices, RSI, ratings |
| `admin_stocks.py` | Add/remove stocks, seed watchlist |
| `update_stocks.py` | Fetch latest prices (runs via GitHub Actions) |
| `send_telegram.py` | Send messages to your Telegram bot |
| `tracker_check_template.py` | Template for personal price alerts |

## Privacy

Everything is completely private:
- Your own Telegram bot
- Your own Supabase database
- Your own GitHub Actions
- No shared data, no tracking, no accounts

## License

Personal use. Fork and customize for your own trading setup.
