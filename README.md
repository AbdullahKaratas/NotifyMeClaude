# Silver Hawk Trading

AI-powered trading analysis and price alerts via Telegram. Built with Claude Code, yfinance, and Supabase.

## What It Does

- **Multi-Agent Analysis:** 4-step pipeline (data collection, bull/bear debate, judge verdict, trading card) for any stock or commodity
- **LONG & SHORT Signals:** Scorecard-based evaluation ensures SHORT trades are treated equally
- **3-Step KO Calculation:** ATR-based + chart-support combined, asset-class adjusted (Large Cap 2x, Mid/Small 2.5x, Commodities 3x)
- **Risk Management:** 10% max per trade, 40% max simultaneous risk, 60% max sector concentration
- **Correlation Check:** Reads open positions from Supabase before every new trade
- **Time-Stops:** Auto-halve after 5 days sideways, close after 8 days, secure 50% before earnings
- **Price Alerts:** Telegram notifications on big moves, level crossings, and flash spikes
- **Portfolio Health Check:** 3x daily RSI alerts for all open positions and watchlist

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
> /analyse-stock AAPL
```

Full setup guide: **[ONBOARDING.md](ONBOARDING.md)** (DE) | **[ONBOARDING_EN.md](ONBOARDING_EN.md)** (EN)

## Requirements

- **Claude Pro** ($20/month) - for Claude Code
- **Telegram** (free) - create a bot via @BotFather
- **Supabase** (free tier) - database and storage
- **GitHub Actions** (free) - automated price updates and alerts

## Architecture

```
You (Claude Code)
├── /analyse-stock NVDA                          → 4-step analysis → Telegram
├── python3 browse_stocks.py                     → View watchlist
└── python3 admin_stocks.py add TSLA ...         → Manage watchlist

GitHub Actions (automatic)
├── update_stocks.yml (every 30 min)             → Update prices, RSI, SMAs
├── tracker.yml (every 10 min)                   → Price alerts → Telegram
└── portfolio_check.yml (3x daily)               → RSI alerts for positions + watchlist

Supabase (your own instance)
├── stocks table                                 → Watchlist with live data
├── reminders table                              → Analysis results
├── portfolio table                              → Open/closed positions + cash
├── tracker_state table                          → Alert state persistence
└── charts/ bucket                               → Chart images
```

## Analysis Pipeline

```
/analyse-stock NVDA
```

| Step | What Happens |
|------|-------------|
| 1. Data Collection | yfinance prices, RSI, MACD, SMAs, ATR, short interest, news, correlation check, event calendar |
| 2. Investment Debate | Bull vs Bear - 2 full rounds + LONG vs SHORT scorecard (6 criteria, /60) |
| 3. Judge & Risk | Verdict + confidence %, 3-step KO (ATR + chart + take further), position sizing in % of portfolio, time-stops |
| 4. Trading Card | Summary card + full analysis → Telegram message + chart photo + Supabase |

## Scripts

| Script | Purpose |
|--------|---------|
| `browse_stocks.py` | View watchlist with prices, RSI, ratings |
| `admin_stocks.py` | Add/remove stocks, seed watchlist |
| `update_stocks.py` | Fetch latest prices (runs via GitHub Actions) |
| `portfolio_check.py` | RSI alerts for positions + watchlist (3x daily) |
| `send_telegram.py` | Send messages and photos to your Telegram bot |
| `supabase_client.py` | Shared Supabase client module |
| `tracker_check_template.py` | Template for personal price alerts |

## Privacy

Everything is completely private:
- Your own Telegram bot
- Your own Supabase database
- Your own GitHub Actions
- No shared data, no tracking, no accounts

## License

Personal use. Fork and customize for your own trading setup.
