#!/usr/bin/env python3
"""Silver Hawk Trading - Stock Data Updater (GitHub Actions).
Reads active symbols from Supabase stocks table, fetches yfinance data, updates back."""

import urllib.parse
from datetime import datetime, timezone

from supabase_client import supabase_request


def get_active_symbols():
    """Fetch list of active symbols from stocks table."""
    result = supabase_request('GET', 'stocks?select=symbol&is_active=eq.true')
    if not result:
        return []
    return [row['symbol'] for row in result]


def fetch_stock_data(symbols):
    """Fetch price, RSI, SMAs, and rating for each symbol via yfinance."""
    import yfinance as yf
    import numpy as np

    results = {}
    for sym in symbols:
        try:
            t = yf.Ticker(sym)
            info = t.info
            hist = t.history(period='3mo')

            rsi = None
            sma50 = None
            sma200 = None

            if len(hist) >= 14:
                delta = hist['Close'].diff()
                gain = delta.where(delta > 0, 0).ewm(alpha=1/14, min_periods=14).mean()
                loss = (-delta.where(delta < 0, 0)).ewm(alpha=1/14, min_periods=14).mean()
                rs = gain / loss
                rsi_val = float((100 - (100 / (1 + rs))).iloc[-1])
                if not np.isnan(rsi_val):
                    rsi = round(rsi_val, 1)

            if len(hist) >= 50:
                sma50 = round(float(hist['Close'].rolling(50).mean().iloc[-1]), 2)

            hist_long = t.history(period='1y')
            if len(hist_long) >= 200:
                sma200 = round(float(hist_long['Close'].rolling(200).mean().iloc[-1]), 2)

            rating = info.get('recommendationKey')
            if rating:
                rating = rating.replace('_', ' ').title()

            results[sym] = {
                'price': info.get('regularMarketPrice'),
                'change_pct': round(info.get('regularMarketChangePercent', 0), 2),
                'rsi': rsi,
                'sma50': sma50,
                'sma200': sma200,
                'market_cap': info.get('marketCap'),
                'volume': info.get('regularMarketVolume'),
                'analyst_rating': rating,
            }
            r = results[sym]
            print(f'  {sym}: ${r["price"]} ({r["change_pct"]:+.1f}%) RSI={rsi} SMA50={sma50} SMA200={sma200} [{rating}]')

        except Exception as e:
            print(f'  {sym}: ERROR - {e}')
            results[sym] = None

    return results


def update_supabase(data):
    """Update stock data in Supabase."""
    now = datetime.now(timezone.utc).isoformat()
    updated = 0

    for sym, vals in data.items():
        if vals is None:
            continue

        row = {'last_updated': now}
        for key in ('price', 'change_pct', 'rsi', 'sma50', 'sma200', 'market_cap', 'volume', 'analyst_rating'):
            if vals.get(key) is not None:
                row[key] = vals[key]

        result = supabase_request('PATCH', f'stocks?symbol=eq.{urllib.parse.quote(sym)}', row)
        if result is not None:
            updated += 1

    return updated


def main():
    now = datetime.now(timezone.utc)
    print(f'[{now.strftime("%H:%M:%S")} UTC] Stock Data Update')

    symbols = get_active_symbols()
    if not symbols:
        print('  No active symbols found.')
        return

    print(f'  Updating {len(symbols)} symbols: {", ".join(symbols)}')

    data = fetch_stock_data(symbols)
    updated = update_supabase(data)

    print(f'  Done! Updated {updated}/{len(symbols)} stocks.')


if __name__ == '__main__':
    main()
