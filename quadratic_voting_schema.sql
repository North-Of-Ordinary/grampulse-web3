-- ═══════════════════════════════════════════════════════════════════════════
-- QUADRATIC VOTING SCHEMA FOR GRAMPULSE
-- Cost = Votes² (e.g., 10 votes costs 100 credits)
-- Enables intensity-based prioritization over simple headcount
-- ═══════════════════════════════════════════════════════════════════════════

-- 1. User Credits Table
-- Tracks voting power for each user (weekly refresh + volunteer earnings)
CREATE TABLE IF NOT EXISTS user_credits (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    balance INTEGER NOT NULL DEFAULT 100,
    total_earned INTEGER NOT NULL DEFAULT 100,
    total_spent INTEGER NOT NULL DEFAULT 0,
    last_weekly_refresh TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id)
);

-- 2. Incident Votes Table
-- Records individual vote transactions with quadratic cost
CREATE TABLE IF NOT EXISTS incident_votes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    incident_id UUID NOT NULL REFERENCES incidents(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    votes_cast INTEGER NOT NULL CHECK (votes_cast > 0),
    credits_spent INTEGER NOT NULL CHECK (credits_spent > 0),
    encrypted_vote_hash TEXT, -- Inco Network encrypted vote proof
    is_encrypted BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Add weighted_votes column to incidents table
ALTER TABLE incidents 
ADD COLUMN IF NOT EXISTS weighted_votes INTEGER DEFAULT 0;

ALTER TABLE incidents 
ADD COLUMN IF NOT EXISTS vote_count INTEGER DEFAULT 0;

ALTER TABLE incidents 
ADD COLUMN IF NOT EXISTS urgency_score DECIMAL(5,2) DEFAULT 0;

-- 4. Credit Transactions Log (for transparency)
CREATE TABLE IF NOT EXISTS credit_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    amount INTEGER NOT NULL, -- positive = earned, negative = spent
    transaction_type TEXT NOT NULL CHECK (transaction_type IN ('weekly_refresh', 'volunteer_action', 'vote_spent', 'admin_grant')),
    reference_id UUID, -- incident_id for votes, action_id for volunteer
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. Inco Encrypted Votes Table (for privacy-preserving votes)
CREATE TABLE IF NOT EXISTS inco_encrypted_votes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    incident_id UUID NOT NULL REFERENCES incidents(id) ON DELETE CASCADE,
    encrypted_payload TEXT NOT NULL, -- Inco ciphertext
    commitment_hash TEXT NOT NULL, -- For verification
    decrypted_votes INTEGER, -- Only revealed after voting period ends
    is_revealed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ═══════════════════════════════════════════════════════════════════════════
-- INDEXES FOR PERFORMANCE
-- ═══════════════════════════════════════════════════════════════════════════

CREATE INDEX IF NOT EXISTS idx_user_credits_user_id ON user_credits(user_id);
CREATE INDEX IF NOT EXISTS idx_incident_votes_incident_id ON incident_votes(incident_id);
CREATE INDEX IF NOT EXISTS idx_incident_votes_user_id ON incident_votes(user_id);
CREATE INDEX IF NOT EXISTS idx_incidents_weighted_votes ON incidents(weighted_votes DESC);
CREATE INDEX IF NOT EXISTS idx_credit_transactions_user_id ON credit_transactions(user_id);

-- ═══════════════════════════════════════════════════════════════════════════
-- FUNCTIONS & TRIGGERS
-- ═══════════════════════════════════════════════════════════════════════════

-- Function to update incident weighted_votes when votes are cast
CREATE OR REPLACE FUNCTION update_incident_votes()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE incidents 
    SET 
        weighted_votes = COALESCE((
            SELECT SUM(votes_cast) FROM incident_votes WHERE incident_id = NEW.incident_id
        ), 0),
        vote_count = COALESCE((
            SELECT COUNT(*) FROM incident_votes WHERE incident_id = NEW.incident_id
        ), 0),
        urgency_score = COALESCE((
            SELECT AVG(credits_spent::DECIMAL / votes_cast) FROM incident_votes WHERE incident_id = NEW.incident_id
        ), 0)
    WHERE id = NEW.incident_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to auto-update votes
DROP TRIGGER IF EXISTS trigger_update_incident_votes ON incident_votes;
CREATE TRIGGER trigger_update_incident_votes
AFTER INSERT ON incident_votes
FOR EACH ROW EXECUTE FUNCTION update_incident_votes();

-- Function for weekly credit refresh
CREATE OR REPLACE FUNCTION refresh_weekly_credits()
RETURNS void AS $$
BEGIN
    UPDATE user_credits 
    SET 
        balance = balance + 100,
        total_earned = total_earned + 100,
        last_weekly_refresh = NOW(),
        updated_at = NOW()
    WHERE last_weekly_refresh < NOW() - INTERVAL '7 days';
    
    -- Log the refresh
    INSERT INTO credit_transactions (user_id, amount, transaction_type, description)
    SELECT user_id, 100, 'weekly_refresh', 'Weekly credit refresh'
    FROM user_credits 
    WHERE last_weekly_refresh < NOW() - INTERVAL '7 days';
END;
$$ LANGUAGE plpgsql;

-- ═══════════════════════════════════════════════════════════════════════════
-- ROW LEVEL SECURITY
-- ═══════════════════════════════════════════════════════════════════════════

ALTER TABLE user_credits ENABLE ROW LEVEL SECURITY;
ALTER TABLE incident_votes ENABLE ROW LEVEL SECURITY;
ALTER TABLE credit_transactions ENABLE ROW LEVEL SECURITY;

-- Users can read their own credits
CREATE POLICY "Users can view own credits" ON user_credits
    FOR SELECT USING (auth.uid() = user_id);

-- Users can update their own credits (for spending)
CREATE POLICY "Users can update own credits" ON user_credits
    FOR UPDATE USING (auth.uid() = user_id);

-- Anyone can view votes (transparency)
CREATE POLICY "Anyone can view votes" ON incident_votes
    FOR SELECT USING (true);

-- Users can insert their own votes
CREATE POLICY "Users can insert own votes" ON incident_votes
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can view their own transactions
CREATE POLICY "Users can view own transactions" ON credit_transactions
    FOR SELECT USING (auth.uid() = user_id);

-- ═══════════════════════════════════════════════════════════════════════════
-- DEMO DATA - Cricket Pitch vs Broken Well
-- ═══════════════════════════════════════════════════════════════════════════

-- Run this after creating the tables to set up the demo scenario
-- INSERT INTO incidents (title, description, category_id, reporter_id, status, severity)
-- VALUES 
--   ('Cricket Pitch Needed', 'Youth want a cricket pitch for recreational activities', '...', '...', 'new', 1),
--   ('Broken Well - No Water', 'Village well is broken, 5 families have no water access', '...', '...', 'new', 3);

-- Enable realtime for voting tables
ALTER PUBLICATION supabase_realtime ADD TABLE incident_votes;
ALTER PUBLICATION supabase_realtime ADD TABLE user_credits;
ALTER PUBLICATION supabase_realtime ADD TABLE incidents;
