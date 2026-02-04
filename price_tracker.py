#!/usr/bin/env python3
"""Silver Hawk Trading - Smart Price Tracker
Checks every 5 min, only alerts when something dramatic happens."""

import urllib.request
import urllib.parse
import json
import time
import sys
import os
from datetime import datetime


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

TOKEN = os.environ['TELEGRAM_BOT_TOKEN']
CHAT_ID = os.environ['TELEGRAM_CHAT_ID']
YFINANCE_PYTHON = os.environ.get('YFINANCE_VENV', 'python3')
API = f'https://api.telegram.org/bot{TOKEN}'

SYMBOLS = {
    'SI=F': {'name': 'Silber', 'emoji': '🥈'},
    'AAPL': {'name': 'Apple', 'emoji': '🍎'},
    'QBTS': {'name': 'D-Wave', 'emoji': '⚛️'},
    'WDC':  {'name': 'Western Digital', 'emoji': '💾'},
}

# ── Alert Thresholds ──
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

prev_prices = {}
alerted_levels = set()
last_summary_hour = -1


def get_prices():
    """Fetch current prices via yfinance."""
    import subprocess
    symbols = json.dumps(list(SYMBOLS.keys()))
    script = f'''
import yfinance as yf
import json
symbols = {symbols}
result = {{}}
for sym in symbols:
    try:
        t = yf.Ticker(sym)
        info = t.info
        result[sym] = {{
            "price": info.get("regularMarketPrice", 0),
            "change_pct": info.get("regularMarketChangePercent", 0),
            "day_high": info.get("dayHigh", 0),
            "day_low": info.get("dayLow", 0),
            "prev_close": info.get("previousClose", 0),
            "market_state": info.get("marketState", "UNKNOWN"),
        }}
    except Exception as e:
        result[sym] = {{"error": str(e)}}
print(json.dumps(result))
'''
    proc = subprocess.run(
        [YFINANCE_PYTHON, '-c', script],
        capture_output=True, text=True, timeout=60
    )
    if proc.returncode != 0:
        raise Exception(f'yfinance error: {proc.stderr}')
    return json.loads(proc.stdout)


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


def check_alerts(prices):
    """Check all alert conditions. Returns list of alert messages."""
    alerts = []

    for sym, meta in SYMBOLS.items():
        data = prices.get(sym, {})
        if 'error' in data or not data.get('price'):
            continue

        price = data['price']
        change = data['change_pct']

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


def format_summary(prices):
    """Format a quiet hourly summary."""
    now = datetime.now().strftime('%H:%M')
    lines = [f'🦅 <b>Stündliches Update</b> | {now} CET', '']

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


def run_tracker(interval=300):
    """Main loop."""
    global prev_prices, last_summary_hour

    print(f'Silver Hawk Tracker (Smart Mode)')
    print(f'Tracking: {", ".join(SYMBOLS.keys())} alle {interval}s')
    print()

    tracking_list = ", ".join(m["emoji"] + " " + m["name"] for m in SYMBOLS.values())
    send_telegram(
        f'🦅 <b>Silver Hawk Tracker (Smart Mode)</b>\n\n'
        f'🔕 Stille Updates jede Stunde\n'
        f'🔔 Sofort-Alert bei dramatischen Moves\n\n'
        f'Tracking: {tracking_list}\n\n'
        f'<i>Kein Spam, nur was zählt.</i>',
        silent=True
    )

    cycle = 0
    while True:
        try:
            cycle += 1
            now = datetime.now()
            hour = now.hour
            print(f'[{now.strftime("%H:%M:%S")}] #{cycle}', end=' ')

            prices = get_prices()

            alerts = check_alerts(prices)
            for alert in alerts:
                send_telegram(alert['text'], silent=alert['silent'])
                print(f'ALERT SENT!', end=' ')

            if hour != last_summary_hour and now.minute < 6:
                msg = format_summary(prices)
                send_telegram(msg, silent=True)
                last_summary_hour = hour
                print(f'[summary]', end=' ')

            for sym, data in prices.items():
                if 'price' in data:
                    p = data['price']
                    c = data['change_pct']
                    print(f'{sym}=${p:.2f}({c:+.1f}%)', end=' ')
                    prev_prices[sym] = p

            print()

        except KeyboardInterrupt:
            print('\nStopped.')
            send_telegram('🦅 Tracker gestoppt.', silent=True)
            break
        except Exception as e:
            print(f'Error: {e}')

        time.sleep(interval)


if __name__ == '__main__':
    interval = int(sys.argv[1]) if len(sys.argv) > 1 else 300
    run_tracker(interval)
