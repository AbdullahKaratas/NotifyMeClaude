#!/usr/bin/env python3
"""Silver Hawk Trading - Single Check (for GitHub Actions).
Runs once, checks prices, sends alerts if needed, then exits.
State is persisted in Supabase."""

import urllib.request
import urllib.parse
import json
import os
from datetime import datetime, timezone

# ── Config from environment ──
TOKEN = os.environ['TELEGRAM_BOT_TOKEN']
CHAT_ID = os.environ['TELEGRAM_CHAT_ID']
SUPABASE_URL = os.environ['SUPABASE_URL']
SUPABASE_KEY = os.environ['SUPABASE_ANON_KEY']
API = f'https://api.telegram.org/bot{TOKEN}'

SYMBOLS = {
    'SI=F': {'name': 'Silber', 'emoji': '🥈'},
    'AAPL': {'name': 'Apple', 'emoji': '🍎'},
    'QBTS': {'name': 'D-Wave', 'emoji': '⚛️'},
    'WDC':  {'name': 'Western Digital', 'emoji': '💾'},
}

ALERT_RULES = {
    'flash_move_pct': 1.5,
    'big_daily_move_pct': 5.0,
    'SI=F': {
        'above': [92, 95, 100],
        'below': [85, 82, 80, 79],
    },
    'QBTS': {
        'above': [25, 30],
        'below': [18, 15],
    },
    'AAPL': {
        'above': [290, 300],
        'below': [260, 250],
    },
    'WDC': {
        'above': [290, 296, 310],
        'below': [255, 250, 240, 230],
    },
}


# ── Supabase State ──

def supabase_request(method, path, data=None):
    """Make a request to Supabase REST API."""
    url = f'{SUPABASE_URL}/rest/v1/{path}'
    body = json.dumps(data).encode() if data else None
    req = urllib.request.Request(url, data=body, method=method)
    req.add_header('apikey', SUPABASE_KEY)
    req.add_header('Authorization', f'Bearer {SUPABASE_KEY}')
    req.add_header('Content-Type', 'application/json')
    req.add_header('Prefer', 'return=representation')
    try:
        resp = urllib.request.urlopen(req)
        return json.loads(resp.read())
    except Exception as e:
        print(f'  Supabase error: {e}')
        return None


def load_state():
    """Load tracker state from Supabase."""
    result = supabase_request('GET', 'tracker_state?select=key,value')
    if not result:
        return {}, set(), -1
    state = {row['key']: row['value'] for row in result}
    prev_prices = state.get('prev_prices', {})
    alerted_levels = set(state.get('alerted_levels', []))
    last_summary_hour = state.get('last_summary_hour', -1)
    return prev_prices, alerted_levels, last_summary_hour


def save_state(prev_prices, alerted_levels, last_summary_hour):
    """Save tracker state to Supabase via upsert."""
    items = [
        {'key': 'prev_prices', 'value': prev_prices, 'updated_at': datetime.now(timezone.utc).isoformat()},
        {'key': 'alerted_levels', 'value': list(alerted_levels), 'updated_at': datetime.now(timezone.utc).isoformat()},
        {'key': 'last_summary_hour', 'value': last_summary_hour, 'updated_at': datetime.now(timezone.utc).isoformat()},
    ]
    for item in items:
        # Upsert via POST with on_conflict
        url = f'tracker_state?on_conflict=key'
        req = urllib.request.Request(
            f'{SUPABASE_URL}/rest/v1/{url}',
            data=json.dumps(item).encode(),
            method='POST'
        )
        req.add_header('apikey', SUPABASE_KEY)
        req.add_header('Authorization', f'Bearer {SUPABASE_KEY}')
        req.add_header('Content-Type', 'application/json')
        req.add_header('Prefer', 'resolution=merge-duplicates')
        try:
            urllib.request.urlopen(req)
        except Exception as e:
            print(f'  State save error: {e}')


# ── Price Fetching ──

def get_prices():
    """Fetch current prices via yfinance."""
    import yfinance as yf
    result = {}
    for sym in SYMBOLS:
        try:
            t = yf.Ticker(sym)
            info = t.info
            result[sym] = {
                'price': info.get('regularMarketPrice', 0),
                'change_pct': info.get('regularMarketChangePercent', 0),
                'day_high': info.get('dayHigh', 0),
                'day_low': info.get('dayLow', 0),
                'prev_close': info.get('previousClose', 0),
                'market_state': info.get('marketState', 'UNKNOWN'),
            }
        except Exception as e:
            result[sym] = {'error': str(e)}
    return result


# ── Telegram ──

def send_telegram(text, silent=True):
    """Send message via Telegram."""
    data = urllib.parse.urlencode({
        'chat_id': CHAT_ID,
        'parse_mode': 'HTML',
        'text': text,
        'disable_notification': 'true' if silent else 'false',
    }).encode()
    req = urllib.request.Request(f'{API}/sendMessage', data=data)
    try:
        resp = urllib.request.urlopen(req)
        return json.loads(resp.read())
    except Exception as e:
        print(f'  Telegram error: {e}')
        return None


# ── Alert Logic ──

def check_alerts(prices, prev_prices, alerted_levels):
    """Check all alert conditions. Returns list of alert messages."""
    alerts = []

    for sym, meta in SYMBOLS.items():
        data = prices.get(sym, {})
        if 'error' in data or not data.get('price'):
            continue

        price = data['price']
        change = data['change_pct']

        # Flash move (vs previous check)
        if sym in prev_prices and prev_prices[sym] > 0:
            move = ((price / prev_prices[sym]) - 1) * 100
            if abs(move) >= ALERT_RULES['flash_move_pct']:
                direction = '📈 SPIKE' if move > 0 else '📉 DROP'
                alerts.append({
                    'text': (f'⚡ <b>{direction}: {meta["emoji"]} {meta["name"]}</b>\n'
                             f'${price:.2f} ({move:+.1f}% in 5 Min!)\n'
                             f'Tageschange: {change:+.1f}%'),
                    'silent': False,
                })

        # Price level crossings
        if sym in ALERT_RULES:
            levels = ALERT_RULES[sym]
            for lvl in levels.get('above', []):
                key = f'{sym}_above_{lvl}'
                if price >= lvl and key not in alerted_levels:
                    alerted_levels.add(key)
                    alerted_levels.discard(f'{sym}_below_{lvl}')
                    alerts.append({
                        'text': (f'🚨 <b>{meta["emoji"]} {meta["name"]} ÜBER ${lvl}!</b>\n'
                                 f'Aktuell: ${price:.2f} ({change:+.1f}%)'),
                        'silent': False,
                    })
            for lvl in levels.get('below', []):
                key = f'{sym}_below_{lvl}'
                if price <= lvl and key not in alerted_levels:
                    alerted_levels.add(key)
                    alerted_levels.discard(f'{sym}_above_{lvl}')
                    alerts.append({
                        'text': (f'🚨 <b>{meta["emoji"]} {meta["name"]} UNTER ${lvl}!</b>\n'
                                 f'Aktuell: ${price:.2f} ({change:+.1f}%)'),
                        'silent': False,
                    })

        # Big daily move
        threshold = ALERT_RULES['big_daily_move_pct']
        for t in [threshold, threshold * 2, threshold * 3]:
            key = f'{sym}_daily_{int(t)}'
            if abs(change) >= t and key not in alerted_levels:
                alerted_levels.add(key)
                emoji = '🟢' if change > 0 else '🔴'
                alerts.append({
                    'text': (f'{emoji} <b>{meta["emoji"]} {meta["name"]}: {change:+.1f}% heute!</b>\n'
                             f'Aktuell: ${price:.2f}\n'
                             f'Range: ${data["day_low"]:.2f} - ${data["day_high"]:.2f}'),
                    'silent': False,
                })

    return alerts


def format_summary(prices, prev_prices):
    """Format a quiet hourly summary."""
    now = datetime.now(timezone.utc).strftime('%H:%M')
    lines = [f'🦅 <b>Stündliches Update</b> | {now} UTC', '']

    for sym, meta in SYMBOLS.items():
        data = prices.get(sym, {})
        if 'error' in data:
            continue
        price = data['price']
        change = data['change_pct']
        arrow = '🟢' if change > 0.5 else '🔴' if change < -0.5 else '⚪'

        move_txt = ''
        if sym in prev_prices and prev_prices[sym] > 0:
            move = ((price / prev_prices[sym]) - 1) * 100
            if abs(move) > 0.1:
                move_txt = f' ({"↑" if move > 0 else "↓"}{abs(move):.1f}%/5m)'

        lines.append(f'{arrow} {meta["emoji"]} <b>{meta["name"]}</b>: ${price:.2f} ({change:+.1f}%){move_txt}')

    return '\n'.join(lines)


# ── Main ──

def main():
    now = datetime.now(timezone.utc)
    hour = now.hour
    print(f'[{now.strftime("%H:%M:%S")} UTC] Silver Hawk Check')

    # Load state
    prev_prices, alerted_levels, last_summary_hour = load_state()

    # Fetch prices
    prices = get_prices()

    # Check alerts
    alerts = check_alerts(prices, prev_prices, alerted_levels)
    for alert in alerts:
        send_telegram(alert['text'], silent=alert['silent'])
        print(f'  ALERT SENT: {alert["text"][:60]}...')

    # Hourly summary
    if hour != last_summary_hour and now.minute < 11:
        msg = format_summary(prices, prev_prices)
        send_telegram(msg, silent=True)
        last_summary_hour = hour
        print(f'  [summary sent]')

    # Update prev_prices
    for sym, data in prices.items():
        if 'price' in data:
            p = data['price']
            c = data['change_pct']
            print(f'  {sym}=${p:.2f}({c:+.1f}%)')
            prev_prices[sym] = p

    # Save state
    save_state(prev_prices, alerted_levels, last_summary_hour)
    print('  [state saved]')


if __name__ == '__main__':
    main()
