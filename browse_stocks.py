#!/usr/bin/env python3
"""Silver Hawk Trading - Stock Watchlist Browser.
Read-only view of the shared stock watchlist."""

import json
import sys

from supabase_client import supabase_request


def fetch_stocks():
    """Fetch active stocks from Supabase."""
    return supabase_request('GET', 'stocks?select=*&is_active=eq.true&order=sector,symbol') or []


def format_table(stocks):
    """Format stocks as a readable table grouped by sector."""
    if not stocks:
        print('No stocks in watchlist.')
        return

    print()
    print('=' * 90)
    print('  SILVER HAWK TRADING - Watchlist')
    print('=' * 90)

    last_update = stocks[0].get('last_updated', '')
    if last_update:
        print(f'  Last updated: {last_update[:16].replace("T", " ")} UTC')
    print()

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

        rsi_mark = ''
        if s.get('rsi'):
            if s['rsi'] >= 70:
                rsi_mark = '!'
            elif s['rsi'] <= 30:
                rsi_mark = '*'

        print(f'  {s["symbol"]:<10} {s["name"]:<22} {price:>10} {chg:>8} {rsi:>5}{rsi_mark} {sma50:>10} {sma200:>10} {rating:<12}')

    print()
    print(f'  {len(stocks)} stocks | RSI: * = oversold (<30), ! = overbought (>70)')
    print()
    print('  To analyze a stock:')
    print('    Analysiere <SYMBOL> @prompts/00_master.md')
    print()


if __name__ == '__main__':
    stocks = fetch_stocks()

    if len(sys.argv) > 1 and sys.argv[1] == '--json':
        print(json.dumps(stocks, indent=2, default=str))
    else:
        format_table(stocks)
