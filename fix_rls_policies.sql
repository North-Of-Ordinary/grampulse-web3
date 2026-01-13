-- ═══════════════════════════════════════════════════════════════════════════
-- FIX ROW LEVEL SECURITY POLICIES FOR QUADRATIC VOTING
-- Run this in Supabase SQL Editor to fix authentication errors
-- ═══════════════════════════════════════════════════════════════════════════

-- Drop ALL existing policies to avoid conflicts
DROP POLICY IF EXISTS "Users can view own credits" ON user_credits;
DROP POLICY IF EXISTS "Users can insert own credits" ON user_credits;
DROP POLICY IF EXISTS "Users can update own credits" ON user_credits;
DROP POLICY IF EXISTS "Service role can manage all credits" ON user_credits;

DROP POLICY IF EXISTS "Anyone can view votes" ON incident_votes;
DROP POLICY IF EXISTS "Users can insert own votes" ON incident_votes;
DROP POLICY IF EXISTS "Authenticated users can insert votes" ON incident_votes;
DROP POLICY IF EXISTS "Service role can manage all votes" ON incident_votes;

DROP POLICY IF EXISTS "Users can view own transactions" ON credit_transactions;
DROP POLICY IF EXISTS "Service role can insert transactions" ON credit_transactions;

-- ═══════════════════════════════════════════════════════════════════════════
-- USER CREDITS POLICIES
-- ═══════════════════════════════════════════════════════════════════════════

-- Allow users to view their own credits
CREATE POLICY "Users can view own credits" ON user_credits
    FOR SELECT 
    USING (auth.uid() = user_id);

-- Allow users to insert their initial credits (auto-initialization)
CREATE POLICY "Users can insert own credits" ON user_credits
    FOR INSERT 
    WITH CHECK (auth.uid() = user_id);

-- Allow users to update their own credits (for spending/earning)
CREATE POLICY "Users can update own credits" ON user_credits
    FOR UPDATE 
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Allow system to update credits (for admin operations)
CREATE POLICY "Service role can manage all credits" ON user_credits
    FOR ALL 
    USING (auth.role() = 'service_role');

-- ═══════════════════════════════════════════════════════════════════════════
-- INCIDENT VOTES POLICIES
-- ═══════════════════════════════════════════════════════════════════════════

-- Allow anyone to view votes (public voting transparency)
CREATE POLICY "Anyone can view votes" ON incident_votes
    FOR SELECT 
    USING (true);

-- Allow authenticated users to insert votes
CREATE POLICY "Authenticated users can insert votes" ON incident_votes
    FOR INSERT 
    WITH CHECK (auth.uid() = user_id);

-- Allow service role to manage all votes
CREATE POLICY "Service role can manage all votes" ON incident_votes
    FOR ALL 
    USING (auth.role() = 'service_role');

-- ═══════════════════════════════════════════════════════════════════════════
-- CREDIT TRANSACTIONS POLICIES
-- ═══════════════════════════════════════════════════════════════════════════

-- Users can view their own transactions
CREATE POLICY "Users can view own transactions" ON credit_transactions
    FOR SELECT 
    USING (auth.uid() = user_id);

-- Allow system to insert transactions
CREATE POLICY "Service role can insert transactions" ON credit_transactions
    FOR INSERT 
    WITH CHECK (auth.role() = 'service_role');

-- ═══════════════════════════════════════════════════════════════════════════
-- VERIFY POLICIES
-- ═══════════════════════════════════════════════════════════════════════════

-- Check all policies are in place
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual
FROM pg_policies 
WHERE tablename IN ('user_credits', 'incident_votes', 'credit_transactions')
ORDER BY tablename, policyname;
