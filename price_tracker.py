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
    'GOOGL': {'name': 'Alphabet', 'emoji': '🔍'},
    'RKLB': {'name': 'Rocket Lab', 'emoji': '🚀'},
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
        'below': [270, 255, 240, 230, 215],
    },
    'GOOGL': {
        'above': [339, 345, 349, 360],
        'below': [328, 320, 310, 300],
    },
    'RKLB': {
        'above': [75, 88, 99.58, 105],
        'below': [65, 55, 48],
    },
}

# ── AI Trading Context (updated per analysis session) ──
# Last updated: 05.02.2026
TRADING_ZONES = {
    'SI=F': {
        'bias': 'LONG',
        'context': 'Crash von $117 auf $78 am 30.01. Recovery auf $87. Signal LONG 58%. Entscheidungszone $87-92. Updated 05.02.2026.',
        'zones': [
            {'type': 'SELL', 'price': 92, 'dir': 'above',
             'note': 'Kurzfristiger Widerstand! Hoch vom 04.02 ($92.02). Teilgewinne mitnehmen.'},
            {'type': 'SELL', 'price': 100, 'dir': 'above',
             'note': 'Pre-Crash Konsolidierung + 62% Fib-Retracement. Psychologische Marke. Gewinne sichern.'},
            {'type': 'WATCH', 'price': 85, 'dir': 'below',
             'note': 'Unter $85 = bearish. Pivot $83 MUSS halten fuer Recovery-Case.'},
            {'type': 'BUY', 'price': 82, 'dir': 'below',
             'note': 'Kaufzone! Tagestief 04.02. Gestaffelter Einstieg. Strukturelles Angebotsdefizit stuetzt.'},
            {'type': 'BUY', 'price': 80, 'dir': 'below',
             'note': 'Starke Kaufzone. Crash-Tief $78 nah. Solarindustrie-Nachfrage als Boden.'},
            {'type': 'DANGER', 'price': 79, 'dir': 'below',
             'note': 'GEFAHR! Unter Crash-Tief $78. Zweite Abwaertswelle. Alle Positionen schliessen.'},
        ],
    },
    'AAPL': {
        'bias': 'LONG',
        'context': 'Position offen: 213x Turbo HT7817, KO $233.78. +37% im Plus. Q1 Rekord: $143.8B Rev (+16%), EPS $2.84 (+19%). Signal LONG 72%. Updated 05.02.2026.',
        'zones': [
            {'type': 'SELL', 'price': 290, 'dir': 'above',
             'note': 'ATH-Zone! 52W-Hoch $288.62. 50% Gewinn mitnehmen, Rest mit Stop $270 laufen lassen.'},
            {'type': 'SELL', 'price': 300, 'dir': 'above',
             'note': 'Psychologische Marke + Analyst Cluster. Starker Widerstand, Teilverkauf sinnvoll.'},
            {'type': 'WATCH', 'price': 260, 'dir': 'below',
             'note': 'Unter SMA 50 ($268)! Turbo-Gewinn schmilzt. 50% Position schliessen wenn Schlusskurs unter $260.'},
            {'type': 'DANGER', 'price': 250, 'dir': 'below',
             'note': 'GEFAHR! Nur noch 7% ueber KO ($233.78). Unter Januar-Tief $248. Sofort absichern oder raus.'},
        ],
    },
    'QBTS': {
        'bias': 'WATCH',
        'context': 'Position geschlossen mit -97 EUR. Quantum-Hype volatil. Nur mit klarem Setup wieder rein.',
        'zones': [
            {'type': 'BUY', 'price': 15, 'dir': 'below',
             'note': 'Kaufzone für Swing-Trade. Aber nur kleine Position, max 100 EUR.'},
            {'type': 'WATCH', 'price': 18, 'dir': 'below',
             'note': 'Unter $18 wird es interessant. Abwarten auf Bodenbildung.'},
            {'type': 'SELL', 'price': 25, 'dir': 'above',
             'note': 'Wenn Long: Gewinne mitnehmen. Quantum-Aktien übertreiben in beide Richtungen.'},
            {'type': 'SELL', 'price': 30, 'dir': 'above',
             'note': 'Starker Widerstand. Hier wird regelmäßig abverkauft.'},
        ],
    },
    'WDC': {
        'bias': 'HOLD_BUY_ON_DIP',
        'context': 'Post-Earnings -7.2% trotz Q2 Beat. AI-Storage Story intakt, +900% in 12Mo = Mean-Reversion-Risiko. Gestaffelter Entry bei Korrektur.',
        'zones': [
            {'type': 'BUY', 'price': 255, 'dir': 'below',
             'note': 'Erste Kaufzone! Tief-Retest vom 04.02. ($254). Position 25% aufbauen. KO moderat $215.'},
            {'type': 'BUY', 'price': 240, 'dir': 'below',
             'note': 'Starke Kaufzone! Januar-Support $240-243. Position 50% aufbauen. Stop $215.'},
            {'type': 'BUY', 'price': 230, 'dir': 'below',
             'note': 'Aggressive Kaufzone! Letzter starker Support. Position 25%. Wenn das bricht, raus.'},
            {'type': 'WATCH', 'price': 270, 'dir': 'below',
             'note': 'Unter Schlusskurs 04.02. Korrektur setzt sich fort. Abwarten auf tiefere Levels.'},
            {'type': 'SELL', 'price': 290, 'dir': 'above',
             'note': 'Previous Close Widerstand. Wenn Long: Teilgewinne sichern.'},
            {'type': 'SELL', 'price': 296, 'dir': 'above',
             'note': '52W-Hoch/ATH! Starker Widerstand. Komplett raus wenn Long.'},
            {'type': 'DANGER', 'price': 215, 'dir': 'below',
             'note': 'GEFAHR! Unter $215 = These invalidiert. Alle Positionen schliessen.'},
        ],
    },
    'GOOGL': {
        'bias': 'LONG_ON_DIP',
        'context': 'Q4 Earnings Beat (EPS +7.2%, Rev +2.2%). CapEx $180B schockt Markt. Cloud +48%. AH -7%->-2%. Entry bei Ruecksetzer auf $315-325. Signal LONG 62%. Updated 05.02.2026.',
        'zones': [
            {'type': 'BUY', 'price': 320, 'dir': 'below',
             'note': 'SMA 50 Support! Optimale Kaufzone. Turbo LONG mit KO $305. Cloud +48% + EPS Beat stuetzen.'},
            {'type': 'BUY', 'price': 310, 'dir': 'below',
             'note': 'Starke Kaufzone! Unter SMA50. Aggressiv kaufen mit KO $285 (konservativ).'},
            {'type': 'WATCH', 'price': 328, 'dir': 'below',
             'note': 'Unter Earnings-Day-Tief. Korrektur beschleunigt sich. Naechster Halt SMA50 $320.'},
            {'type': 'SELL', 'price': 339, 'dir': 'above',
             'note': 'Previous Close zurueckerobert! Wenn Long: Teilgewinne. Widerstand beachten.'},
            {'type': 'SELL', 'price': 349, 'dir': 'above',
             'note': 'ATH/52W-Hoch! Starker Widerstand. Double-Top-Gefahr. Gewinne sichern.'},
            {'type': 'DANGER', 'price': 300, 'dir': 'below',
             'note': 'GEFAHR! Psychologische Marke + Dezember-Gap. Unter $300 = Antitrust-Panik moeglich.'},
        ],
    },
    'RKLB': {
        'bias': 'HOLD',
        'context': 'Neutron-Rakete + Space Systems wachsen stark. Post-Earnings Korrektur (-7.9%) nach ATH $99.58. Signal HOLD 58%. SHORT-Bias bei Bruch unter $65. Updated 05.02.2026.',
        'zones': [
            {'type': 'BUY', 'price': 65, 'dir': 'below',
             'note': 'Erste Kaufzone! SMA 50 nahe $69.61. Gestaffelter Einstieg. Space-Story langfristig intakt.'},
            {'type': 'BUY', 'price': 55, 'dir': 'below',
             'note': 'Starke Kaufzone! Januar-Support. Position aufbauen. KO $48 fuer Turbo.'},
            {'type': 'BUY', 'price': 48, 'dir': 'below',
             'note': 'Aggressive Kaufzone! Dezember-Tief. Letzter starker Support vor Gap.'},
            {'type': 'WATCH', 'price': 73, 'dir': 'below',
             'note': 'Unter Previous Close $73.11. Korrektur setzt sich fort. Abwarten.'},
            {'type': 'SELL', 'price': 75, 'dir': 'above',
             'note': 'Kurzfristiger Widerstand! Wenn Long: Teilgewinne sichern.'},
            {'type': 'SELL', 'price': 88, 'dir': 'above',
             'note': 'Starker Widerstand! Januar-Hoch. 50% Position schliessen.'},
            {'type': 'SELL', 'price': 99.58, 'dir': 'above',
             'note': 'ATH/52W-Hoch! Maximaler Widerstand. Komplett raus oder enger Stop.'},
            {'type': 'DANGER', 'price': 48, 'dir': 'below',
             'note': 'GEFAHR! Unter Dezember-Support. Grosse Korrektur moeglich. Positionen schliessen.'},
        ],
    },
}


def get_zone_context(sym, price_level, direction):
    """Get AI trading context for a price level."""
    if sym not in TRADING_ZONES:
        return None
    for zone in TRADING_ZONES[sym]['zones']:
        if zone['price'] == price_level and zone['dir'] == direction:
            type_emoji = {'BUY': '🟢', 'SELL': '🔴', 'WATCH': '👀', 'STOP': '⚠️', 'DANGER': '🔥'}.get(zone['type'], '')
            return f'{type_emoji} {zone["note"]}'
    return None


def get_zone_status(sym, price):
    """Get current zone status for a symbol in hourly summary."""
    if sym not in TRADING_ZONES:
        return ''
    zones = TRADING_ZONES[sym]
    nearest = None
    nearest_dist = float('inf')
    for zone in zones['zones']:
        dist = abs(price - zone['price'])
        if dist < nearest_dist:
            nearest_dist = dist
            nearest = zone
    if not nearest:
        return ''
    pct_away = ((nearest['price'] - price) / price) * 100
    if abs(pct_away) < 1:
        return f' ⬅️ {nearest["type"]} Zone!'
    elif abs(pct_away) < 5:
        return f' ({abs(pct_away):.1f}% bis {nearest["type"]} ${nearest["price"]})'
    return ''


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
                    zone_note = get_zone_context(sym, lvl, 'above')
                    text = f'🚨 <b>{meta["emoji"]} {meta["name"]} ÜBER ${lvl}!</b>\n'
                    text += f'Aktuell: ${price:.2f} ({change:+.1f}%)'
                    if zone_note:
                        text += f'\n\n🤖 <i>{zone_note}</i>'
                    alerts.append({'text': text, 'silent': False})
            for lvl in levels.get('below', []):
                key = f'{sym}_below_{lvl}'
                if price <= lvl and key not in alerted_levels:
                    alerted_levels.add(key)
                    alerted_levels.discard(f'{sym}_above_{lvl}')
                    zone_note = get_zone_context(sym, lvl, 'below')
                    text = f'🚨 <b>{meta["emoji"]} {meta["name"]} UNTER ${lvl}!</b>\n'
                    text += f'Aktuell: ${price:.2f} ({change:+.1f}%)'
                    if zone_note:
                        text += f'\n\n🤖 <i>{zone_note}</i>'
                    alerts.append({'text': text, 'silent': False})

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

        zone_txt = get_zone_status(sym, price)
        lines.append(f'{arrow} {meta["emoji"]} <b>{meta["name"]}</b>: ${price:.2f} ({change:+.1f}%){move_txt}{zone_txt}')

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
