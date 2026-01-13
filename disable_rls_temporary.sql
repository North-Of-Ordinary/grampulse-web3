-- ═══════════════════════════════════════════════════════════════════════════
-- TEMPORARY: DISABLE RLS FOR TESTING
-- ⚠️ WARNING: Only use this for development/testing, NOT production!
-- ═══════════════════════════════════════════════════════════════════════════

-- Disable RLS on all tables
ALTER TABLE user_credits DISABLE ROW LEVEL SECURITY;
ALTER TABLE incident_votes DISABLE ROW LEVEL SECURITY;
ALTER TABLE credit_transactions DISABLE ROW LEVEL SECURITY;

-- Grant all permissions to authenticated users (temporary)
GRANT ALL ON user_credits TO authenticated;
GRANT ALL ON incident_votes TO authenticated;
GRANT ALL ON credit_transactions TO authenticated;

-- ═══════════════════════════════════════════════════════════════════════════
-- TO RE-ENABLE RLS LATER, RUN:
-- ALTER TABLE user_credits ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE incident_votes ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE credit_transactions ENABLE ROW LEVEL SECURITY;
-- ═══════════════════════════════════════════════════════════════════════════
