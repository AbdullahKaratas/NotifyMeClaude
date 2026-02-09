-- ============================================================
-- NotifyMe Claude - Supabase Database Schema
-- ============================================================
-- Run this in your Supabase SQL Editor:
-- https://supabase.com/dashboard/project/YOUR_PROJECT/sql
-- ============================================================

-- Create the reminders table
CREATE TABLE IF NOT EXISTS reminders (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    due_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    is_done BOOLEAN DEFAULT FALSE
);

-- Enable Realtime for the reminders table
-- This allows the Flutter app to receive live updates
ALTER TABLE reminders REPLICA IDENTITY FULL;

-- Enable Row Level Security (RLS)
-- For personal use, we allow all operations
ALTER TABLE reminders ENABLE ROW LEVEL SECURITY;

-- Policy: Allow all operations for anonymous users
-- This is fine for personal use since only you have the API key
CREATE POLICY "Allow all for anon" ON reminders
    FOR ALL
    USING (true)
    WITH CHECK (true);

-- Optional: Create an index for faster queries
CREATE INDEX IF NOT EXISTS idx_reminders_due_at ON reminders(due_at);
CREATE INDEX IF NOT EXISTS idx_reminders_is_done ON reminders(is_done);

-- ============================================================
-- Shared Stock Watchlist
-- ============================================================
-- Curated stock watchlist updated automatically via GitHub Actions.
-- Friends can read this table to see what's being tracked.

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

CREATE POLICY "Allow all for anon" ON stocks
    FOR ALL
    USING (true)
    WITH CHECK (true);

CREATE INDEX IF NOT EXISTS idx_stocks_is_active ON stocks(is_active);
CREATE INDEX IF NOT EXISTS idx_stocks_sector ON stocks(sector);

-- ============================================================
-- IMPORTANT: Enable Realtime in Supabase Dashboard
-- ============================================================
-- 1. Go to Database > Replication
-- 2. Enable replication for the "reminders" table
-- ============================================================
