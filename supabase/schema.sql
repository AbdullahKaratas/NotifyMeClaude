-- ============================================================
-- NotifyMe Claude - Supabase Database Schema
-- ============================================================
-- Run this in your Supabase SQL Editor:
-- https://supabase.com/dashboard/project/YOUR_PROJECT/sql
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

-- Enable Realtime for the reminders table
ALTER TABLE reminders REPLICA IDENTITY FULL;

-- Enable Row Level Security (RLS)
-- For personal use, we allow all operations
ALTER TABLE reminders ENABLE ROW LEVEL SECURITY;

-- Policy: Allow all operations for anonymous users
-- This is fine for personal use since only you have the API key
CREATE POLICY "Allow all for anon on reminders" ON reminders
    FOR ALL
    USING (true)
    WITH CHECK (true);

CREATE INDEX IF NOT EXISTS idx_reminders_due_at ON reminders(due_at);
CREATE INDEX IF NOT EXISTS idx_reminders_is_done ON reminders(is_done);

-- ============================================================
-- Shared Stock Watchlist
-- ============================================================
-- Curated stock watchlist updated automatically via GitHub Actions.
-- Each instance has its own watchlist in its own Supabase project.

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

CREATE POLICY "Allow all for anon on stocks" ON stocks
    FOR ALL
    USING (true)
    WITH CHECK (true);

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

CREATE POLICY "Allow all for anon on tracker_state" ON tracker_state
    FOR ALL
    USING (true)
    WITH CHECK (true);

-- ============================================================
-- Storage: Create a "charts" bucket in Supabase Dashboard
-- ============================================================
-- 1. Go to Storage > New Bucket
-- 2. Name: "charts"
-- 3. Public: ON
-- ============================================================
