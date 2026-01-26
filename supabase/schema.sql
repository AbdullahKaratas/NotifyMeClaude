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
-- IMPORTANT: Enable Realtime in Supabase Dashboard
-- ============================================================
-- 1. Go to Database > Replication
-- 2. Enable replication for the "reminders" table
-- ============================================================
