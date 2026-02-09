#!/usr/bin/env python3
"""Silver Hawk Trading - Stock Watchlist Browser.
Read-only view of the shared stock watchlist. No API keys needed beyond Supabase."""

import urllib.request
import json
import os
import sys


def _load_env():
    """Load .env file into os.environ."""
    env_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), '.env')
    if os.path.exists(env_path):
        with open(env_path) as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith('#') and '=' in line:
                    key, val = line.split('=', 1)
                    os.environ.setdefault(key.strip(), val.strip())

_load_env()

SUPABASE_URL = os.environ['SUPABASE_URL']
SUPABASE_KEY = os.environ['SUPABASE_ANON_KEY']


def fetch_stocks():
    """Fetch active stocks from Supabase."""
    url = f'{SUPABASE_URL}/rest/v1/stocks?select=*&is_active=eq.true&order=sector,symbol'
    req = urllib.request.Request(url)
    req.add_header('apikey', SUPABASE_KEY)
    req.add_header('Authorization', f'Bearer {SUPABASE_KEY}')
    resp = urllib.request.urlopen(req)
    return json.loads(resp.read())


def format_table(stocks):
    """Format stocks as a readable table grouped by sector."""
    if not stocks:
        print('No stocks in watchlist.')
        return

    # Header
    print()
    print('=' * 90)
    print('  SILVER HAWK TRADING - Watchlist')
    print('=' * 90)

    # Parse last_updated from any stock
    last_update = stocks[0].get('last_updated', '')
    if last_update:
        # Truncate to minute
        last_update = last_update[:16].replace('T', ' ')
        print(f'  Last updated: {last_update} UTC')
    print()

    # Table header
    print(f'  {"Symbol":<10} {"Name":<22} {"Price":>10} {"Chg%":>8} {"RSI":>6} {"SMA50":>10} {"SMA200":>10} {"Rating":<12}')
    print('  ' + '-' * 88)

    current_sector = None
    for s in stocks:
        sector = s.get('sector') or 'Other'
        if sector != current_sector:
            current_sector = sector
            print(f'\n  {sector}')
            print(f'  {"":->88}')

        price = f"${s['price']:.2f}" if s.get('price') else '  -'
        chg = f"{s['change_pct']:+.1f}%" if s.get('change_pct') is not None else '  -'
        rsi = f"{s['rsi']:.0f}" if s.get('rsi') else ' -'
        sma50 = f"${s['sma50']:.0f}" if s.get('sma50') else '  -'
        sma200 = f"${s['sma200']:.0f}" if s.get('sma200') else '  -'
        rating = s.get('analyst_rating') or '-'

        # RSI coloring hint
        rsi_mark = ''
        if s.get('rsi'):
            if s['rsi'] >= 70:
                rsi_mark = '!'  # overbought
            elif s['rsi'] <= 30:
                rsi_mark = '*'  # oversold

        print(f'  {s["symbol"]:<10} {s["name"]:<22} {price:>10} {chg:>8} {rsi:>5}{rsi_mark} {sma50:>10} {sma200:>10} {rating:<12}')

    print()
    print(f'  {len(stocks)} stocks | RSI: * = oversold (<30), ! = overbought (>70)')
    print()
    print('  To analyze a stock:')
    print('    Analysiere <SYMBOL> @prompts/00_master.md')
    print()


def format_json(stocks):
    """Output stocks as JSON."""
    print(json.dumps(stocks, indent=2, default=str))


if __name__ == '__main__':
    fmt = 'table'
    if len(sys.argv) > 1 and sys.argv[1] == '--json':
        fmt = 'json'

    stocks = fetch_stocks()

    if fmt == 'json':
        format_json(stocks)
    else:
        format_table(stocks)
