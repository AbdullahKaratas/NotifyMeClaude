-- ============================================================
-- NotifyMe Claude - Supabase Database Schema
-- ============================================================
-- Run this in your Supabase SQL Editor:
-- https://supabase.com/dashboard/project/YOUR_PROJECT/sql
-- Safe to run multiple times (idempotent).
-- ============================================================

-- Reminders table (for analysis results)
CREATE TABLE IF NOT EXISTS reminders (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    image_url TEXT,
    due_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    is_done BOOLEAN DEFAULT FALSE
);

ALTER TABLE reminders REPLICA IDENTITY FULL;
ALTER TABLE reminders ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow all for anon on reminders" ON reminders;
CREATE POLICY "Allow all for anon on reminders" ON reminders
    FOR ALL USING (true) WITH CHECK (true);

CREATE INDEX IF NOT EXISTS idx_reminders_due_at ON reminders(due_at);
CREATE INDEX IF NOT EXISTS idx_reminders_is_done ON reminders(is_done);

-- ============================================================
-- Shared Stock Watchlist
-- ============================================================

CREATE TABLE IF NOT EXISTS stocks (
    symbol TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    sector TEXT,
    price NUMERIC,
    change_pct NUMERIC,
    rsi NUMERIC,
    sma50 NUMERIC,
    sma200 NUMERIC,
    market_cap BIGINT,
    volume BIGINT,
    analyst_rating TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    added_by TEXT DEFAULT 'admin',
    last_updated TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE stocks ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow all for anon on stocks" ON stocks;
CREATE POLICY "Allow all for anon on stocks" ON stocks
    FOR ALL USING (true) WITH CHECK (true);

CREATE INDEX IF NOT EXISTS idx_stocks_is_active ON stocks(is_active);
CREATE INDEX IF NOT EXISTS idx_stocks_sector ON stocks(sector);

-- ============================================================
-- Tracker State (for price alert persistence in GitHub Actions)
-- ============================================================

CREATE TABLE IF NOT EXISTS tracker_state (
    key TEXT PRIMARY KEY,
    value JSONB NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE tracker_state ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow all for anon on tracker_state" ON tracker_state;
CREATE POLICY "Allow all for anon on tracker_state" ON tracker_state
    FOR ALL USING (true) WITH CHECK (true);

-- ============================================================
-- Portfolio (track open/closed positions)
-- ============================================================

CREATE TABLE IF NOT EXISTS portfolio (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    symbol TEXT NOT NULL,
    product TEXT,
    quantity NUMERIC NOT NULL,
    entry_price NUMERIC,
    ko_level NUMERIC,
    stop_loss NUMERIC,
    target_price NUMERIC,
    status TEXT DEFAULT 'open',
    notes TEXT,
    opened_at TIMESTAMPTZ DEFAULT NOW(),
    closed_at TIMESTAMPTZ,
    close_price NUMERIC,
    pnl_eur NUMERIC,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE portfolio ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow all for anon on portfolio" ON portfolio;
CREATE POLICY "Allow all for anon on portfolio" ON portfolio
    FOR ALL USING (true) WITH CHECK (true);

CREATE INDEX IF NOT EXISTS idx_portfolio_status ON portfolio(status);
CREATE INDEX IF NOT EXISTS idx_portfolio_symbol ON portfolio(symbol);

-- ============================================================
-- Storage: Create a "charts" bucket in Supabase Dashboard
-- ============================================================
-- 1. Go to Storage > New Bucket
-- 2. Name: "charts"
-- 3. Public: ON
-- ============================================================
