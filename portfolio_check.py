#!/usr/bin/env python3
"""Silver Hawk Trading - Portfolio Health Check (GitHub Actions).
Fetches live data for open positions, checks RSI/stops/targets, sends Telegram alert."""

import json
import os
import urllib.parse
import urllib.request
from datetime import datetime, timezone

from supabase_client import supabase_request


def get_open_positions():
    """Fetch open positions from portfolio table."""
    result = supabase_request('GET', 'portfolio?select=*&status=eq.open')
    if not result:
        return []
    return result


def fetch_position_data(positions):
    """Fetch live yfinance data for each position."""
    import yfinance as yf
    import numpy as np

    symbols = list(set(p['symbol'] for p in positions))
    data = {}

    for sym in symbols:
        try:
            t = yf.Ticker(sym)
            info = t.info
            hist = t.history(period='3mo')

            rsi = None
            macd_hist = None

            if len(hist) >= 14:
                delta = hist['Close'].diff()
                gain = delta.where(delta > 0, 0).rolling(window=14).mean()
                loss = (-delta.where(delta < 0, 0)).rolling(window=14).mean()
                rs = gain / loss
                rsi_val = float((100 - (100 / (1 + rs))).iloc[-1])
                if not np.isnan(rsi_val):
                    rsi = round(rsi_val, 1)

            if len(hist) >= 26:
                exp12 = hist['Close'].ewm(span=12, adjust=False).mean()
                exp26 = hist['Close'].ewm(span=26, adjust=False).mean()
                macd = exp12 - exp26
                signal = macd.ewm(span=9, adjust=False).mean()
                macd_hist = round(float((macd - signal).iloc[-1]), 2)

            price = info.get('currentPrice') or info.get('regularMarketPrice', 0)
            prev_close = info.get('previousClose', 0)
            change_pct = ((price - prev_close) / prev_close * 100) if prev_close else 0

            data[sym] = {
                'price': price,
                'change_pct': round(change_pct, 2),
                'rsi': rsi,
                'macd_hist': macd_hist,
                'day_high': info.get('dayHigh', 0),
                'day_low': info.get('dayLow', 0),
                'sma50': info.get('fiftyDayAverage', 0),
                'sma200': info.get('twoHundredDayAverage', 0),
                'market_state': info.get('marketState', 'UNKNOWN'),
            }
        except Exception as e:
            print(f'  {sym}: ERROR - {e}')
            data[sym] = None

    return data


def build_message(positions, data, check_time):
    """Build the Telegram alert message."""
    alerts = []
    lines = []

    for pos in positions:
        sym = pos['symbol']
        d = data.get(sym)
        if not d:
            continue

        price = d['price']
        rsi = d['rsi']
        entry = pos.get('entry_price')
        stop = pos.get('stop_loss')
        target = pos.get('target_price')
        ko = pos.get('ko_level')
        qty = pos.get('quantity', 0)
        product = pos.get('product', '')

        # P&L calculation
        pnl_pct = ((price - entry) / entry * 100) if entry and entry > 0 else 0
        pnl_emoji = '+' if pnl_pct >= 0 else ''

        # RSI alerts
        rsi_flag = ''
        if rsi and rsi > 70:
            rsi_flag = ' OVERBOUGHT'
            alerts.append(f'RSI {sym} bei {rsi:.0f} - VERKAUF ERWAEGEN!')
        elif rsi and rsi < 30:
            rsi_flag = ' OVERSOLD'
            alerts.append(f'RSI {sym} bei {rsi:.0f} - KAUFGELEGENHEIT?')

        # Stop proximity (within 5%)
        if stop and price:
            stop_dist = abs(price - stop) / price * 100
            if stop_dist < 5:
                alerts.append(f'{sym} nur {stop_dist:.1f}% vom Stop ${stop:.0f}!')

        # KO proximity (within 15%)
        if ko and price:
            ko_dist = abs(price - ko) / price * 100
            if ko_dist < 15:
                alerts.append(f'{sym} nur {ko_dist:.1f}% vom KO ${ko:.2f}!')

        # Target proximity (within 5%)
        if target and price:
            target_dist = abs(target - price) / price * 100
            if target_dist < 5:
                alerts.append(f'{sym} fast am Ziel ${target:.0f} ({target_dist:.1f}% entfernt)!')

        # Format position line
        rsi_str = f'{rsi:.0f}{rsi_flag}' if rsi else 'N/A'
        macd_str = 'BULL' if d['macd_hist'] and d['macd_hist'] > 0 else 'BEAR'
        line = f'{sym} ${price:.2f} ({d["change_pct"]:+.1f}%)'
        line += f'\n  RSI: {rsi_str} | MACD: {macd_str}'
        line += f'\n  P&L: {pnl_emoji}{pnl_pct:.1f}% | Qty: {qty:.0f}x'

        if product:
            line += f' ({product})'

        level_parts = []
        if stop:
            level_parts.append(f'Stop ${stop:.0f}')
        if ko:
            level_parts.append(f'KO ${ko:.2f}')
        if target:
            level_parts.append(f'Ziel ${target:.0f}')
        if level_parts:
            line += f'\n  {" | ".join(level_parts)}'

        lines.append(line)

    # Build full message
    market = data.get(positions[0]['symbol'], {}).get('market_state', '') if positions else ''
    market_emoji = 'OPEN' if market in ('REGULAR', 'PRE', 'POST') else 'CLOSED'

    header = f'<b>PORTFOLIO CHECK - {check_time}</b>\n'
    header += f'Markt: {market_emoji}\n'

    # Alert section
    alert_section = ''
    if alerts:
        alert_section = '\n<b>ALERTS</b>\n'
        for a in alerts:
            alert_section += f'  {a}\n'

    # Positions section
    pos_section = '\n<b>POSITIONEN</b>\n'
    pos_section += '\n\n'.join(lines)

    return header + alert_section + pos_section


def send_telegram(text):
    """Send message via Telegram."""
    token = os.environ['TELEGRAM_BOT_TOKEN']
    chat_id = os.environ['TELEGRAM_CHAT_ID']

    body = urllib.parse.urlencode({
        'chat_id': chat_id,
        'parse_mode': 'HTML',
        'text': text
    }).encode()
    req = urllib.request.Request(f'https://api.telegram.org/bot{token}/sendMessage', data=body)
    resp = urllib.request.urlopen(req)
    return json.loads(resp.read())


def main():
    now = datetime.now(timezone.utc)
    check_time = now.strftime('%d.%m.%Y %H:%M UTC')
    print(f'[{now.strftime("%H:%M:%S")} UTC] Portfolio Health Check')

    positions = get_open_positions()
    if not positions:
        print('  No open positions found.')
        return

    print(f'  Checking {len(positions)} positions...')

    data = fetch_position_data(positions)

    for pos in positions:
        sym = pos['symbol']
        d = data.get(sym)
        if d:
            print(f'  {sym}: ${d["price"]:.2f} RSI={d["rsi"]} MACD_H={d["macd_hist"]}')

    msg = build_message(positions, data, check_time)
    result = send_telegram(msg)
    print(f'  Telegram sent: {result.get("ok", False)}')


if __name__ == '__main__':
    main()
