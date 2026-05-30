CREATE TABLE IF NOT EXISTS qadaa.qadaa_progress (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  prayer_name TEXT NOT NULL,
  total_missed INTEGER NOT NULL,
  completed INTEGER NOT NULL DEFAULT 0,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(user_id, prayer_name)
);

CREATE TABLE IF NOT EXISTS qadaa.qadaa_logs (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  prayer_name TEXT NOT NULL,
  count INTEGER NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE qadaa.qadaa_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE qadaa.qadaa_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY qadaa_progress_select_own ON qadaa.qadaa_progress
  FOR SELECT USING (user_id = (select auth.uid()));
CREATE POLICY qadaa_progress_insert_own ON qadaa.qadaa_progress
  FOR INSERT WITH CHECK (user_id = (select auth.uid()));
CREATE POLICY qadaa_progress_update_own ON qadaa.qadaa_progress
  FOR UPDATE USING (user_id = (select auth.uid()));
CREATE POLICY qadaa_progress_delete_own ON qadaa.qadaa_progress
  FOR DELETE USING (user_id = (select auth.uid()));

CREATE POLICY qadaa_logs_select_own ON qadaa.qadaa_logs
  FOR SELECT USING (user_id = (select auth.uid()));
CREATE POLICY qadaa_logs_insert_own ON qadaa.qadaa_logs
  FOR INSERT WITH CHECK (user_id = (select auth.uid()));
CREATE POLICY qadaa_logs_update_own ON qadaa.qadaa_logs
  FOR UPDATE USING (user_id = (select auth.uid()));
CREATE POLICY qadaa_logs_delete_own ON qadaa.qadaa_logs
  FOR DELETE USING (user_id = (select auth.uid()));

GRANT ALL ON qadaa.qadaa_progress TO authenticated;
GRANT ALL ON qadaa.qadaa_progress TO service_role;
GRANT ALL ON qadaa.qadaa_logs TO authenticated;
GRANT ALL ON qadaa.qadaa_logs TO service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA qadaa TO authenticated;
GRANT SELECT ON qadaa.qadaa_progress TO anon;
GRANT SELECT ON qadaa.qadaa_logs TO anon;
