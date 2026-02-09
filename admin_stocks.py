#!/usr/bin/env python3
"""Silver Hawk Trading - Admin CLI for managing the shared stock watchlist."""

import urllib.parse
import sys
from datetime import datetime, timezone

from supabase_client import supabase_request


def list_stocks():
    """List all stocks in the watchlist."""
    result = supabase_request('GET', 'stocks?select=*&order=sector,symbol')
    if not result:
        print('No stocks found or error fetching.')
        return

    current_sector = None
    print(f'\n{"Symbol":<10} {"Name":<25} {"Sector":<15} {"Price":>10} {"Chg%":>8} {"RSI":>6} {"Active":>7}')
    print('-' * 85)

    for s in result:
        sector = s.get('sector') or 'Unknown'
        if sector != current_sector:
            current_sector = sector
            print(f'\n  --- {sector} ---')

        price = f"${s['price']:.2f}" if s.get('price') else '-'
        chg = f"{s['change_pct']:+.1f}%" if s.get('change_pct') is not None else '-'
        rsi = f"{s['rsi']:.0f}" if s.get('rsi') else '-'
        active = 'Yes' if s.get('is_active') else 'No'

        print(f"{s['symbol']:<10} {s['name']:<25} {sector:<15} {price:>10} {chg:>8} {rsi:>6} {active:>7}")

    print(f'\nTotal: {len(result)} stocks')


def add_stock(symbol, name, sector=None):
    """Add a stock to the watchlist."""
    symbol = symbol.upper()
    now = datetime.now(timezone.utc).isoformat()
    data = {
        'symbol': symbol,
        'name': name,
        'sector': sector,
        'is_active': True,
        'added_by': 'admin',
        'created_at': now,
        'last_updated': now,
    }

    result = supabase_request('POST', 'stocks?on_conflict=symbol', data)
    if result:
        print(f'Added: {symbol} ({name}) [{sector or "no sector"}]')
    else:
        print(f'Failed to add {symbol}')


def remove_stock(symbol):
    """Soft-delete a stock (set is_active=False)."""
    symbol = symbol.upper()
    result = supabase_request(
        'PATCH',
        f'stocks?symbol=eq.{urllib.parse.quote(symbol)}',
        {'is_active': False, 'last_updated': datetime.now(timezone.utc).isoformat()}
    )
    if result:
        print(f'Deactivated: {symbol}')
    else:
        print(f'Failed to deactivate {symbol}')


SEED_STOCKS = [
    ('AAPL', 'Apple', 'Technology'),
    ('ARM', 'ARM Holdings', 'Technology'),
    ('NVDA', 'NVIDIA', 'Technology'),
    ('GOOGL', 'Alphabet', 'Technology'),
    ('QBTS', 'D-Wave Quantum', 'Technology'),
    ('WDC', 'Western Digital', 'Technology'),
    ('IREN', 'IREN', 'Technology'),
    ('VST', 'Vistra Energy', 'Energy'),
    ('ENR.DE', 'Siemens Energy', 'Energy'),
    ('RKLB', 'Rocket Lab', 'Aerospace'),
    ('SI=F', 'Silver Futures', 'Commodities'),
    ('GC=F', 'Gold Futures', 'Commodities'),
]


def seed_watchlist():
    """Seed the watchlist with our current tracked symbols."""
    print('Seeding watchlist...')
    for symbol, name, sector in SEED_STOCKS:
        add_stock(symbol, name, sector)
    print(f'\nDone! Seeded {len(SEED_STOCKS)} stocks.')


USAGE = """
Silver Hawk Trading - Stock Admin

Usage:
  python admin_stocks.py list                          Show all stocks
  python admin_stocks.py add NVDA "NVIDIA" Technology  Add a stock
  python admin_stocks.py remove NVDA                   Deactivate a stock
  python admin_stocks.py seed                          Seed initial watchlist
"""


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print(USAGE)
        sys.exit(1)

    cmd = sys.argv[1].lower()

    if cmd == 'list':
        list_stocks()
    elif cmd == 'add':
        if len(sys.argv) < 4:
            print('Usage: python admin_stocks.py add SYMBOL "Name" [Sector]')
            sys.exit(1)
        sector = sys.argv[4] if len(sys.argv) > 4 else None
        add_stock(sys.argv[2], sys.argv[3], sector)
    elif cmd == 'remove':
        if len(sys.argv) < 3:
            print('Usage: python admin_stocks.py remove SYMBOL')
            sys.exit(1)
        remove_stock(sys.argv[2])
    elif cmd == 'seed':
        seed_watchlist()
    else:
        print(USAGE)
