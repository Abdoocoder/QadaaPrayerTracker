CREATE SCHEMA IF NOT EXISTS qadaa;

CREATE TABLE qadaa.prayer_logs (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  prayer_name TEXT NOT NULL,
  completed BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(user_id, date, prayer_name)
);

CREATE TABLE qadaa.prayer_times (
  id BIGSERIAL PRIMARY KEY,
  date DATE UNIQUE NOT NULL,
  fajr TEXT NOT NULL,
  sunrise TEXT NOT NULL,
  dhuhr TEXT NOT NULL,
  asr TEXT NOT NULL,
  maghrib TEXT NOT NULL,
  isha TEXT NOT NULL,
  timezone TEXT NOT NULL DEFAULT 'Asia/Amman',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE qadaa.settings (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  key TEXT NOT NULL,
  value TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(user_id, key)
);

CREATE OR REPLACE FUNCTION qadaa.get_prayer_times_cached(p_date TEXT)
RETURNS TABLE(
  date TEXT,
  fajr TEXT,
  sunrise TEXT,
  dhuhr TEXT,
  asr TEXT,
  maghrib TEXT,
  isha TEXT,
  timezone TEXT
)
LANGUAGE sql STABLE
SET search_path = 'qadaa'
AS $$
  SELECT
    pt.date::TEXT,
    pt.fajr,
    pt.sunrise,
    pt.dhuhr,
    pt.asr,
    pt.maghrib,
    pt.isha,
    pt.timezone
  FROM qadaa.prayer_times pt
  WHERE pt.date::TEXT = p_date
  LIMIT 1;
$$;

ALTER TABLE qadaa.prayer_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE qadaa.settings ENABLE ROW LEVEL SECURITY;

CREATE POLICY prayer_logs_select_own ON qadaa.prayer_logs
  FOR SELECT USING (user_id = (select auth.uid()));
CREATE POLICY prayer_logs_insert_own ON qadaa.prayer_logs
  FOR INSERT WITH CHECK (user_id = (select auth.uid()));
CREATE POLICY prayer_logs_update_own ON qadaa.prayer_logs
  FOR UPDATE USING (user_id = (select auth.uid()));
CREATE POLICY prayer_logs_delete_own ON qadaa.prayer_logs
  FOR DELETE USING (user_id = (select auth.uid()));

CREATE POLICY settings_select_own ON qadaa.settings
  FOR SELECT USING (user_id = (select auth.uid()));
CREATE POLICY settings_insert_own ON qadaa.settings
  FOR INSERT WITH CHECK (user_id = (select auth.uid()));
CREATE POLICY settings_update_own ON qadaa.settings
  FOR UPDATE USING (user_id = (select auth.uid()));
CREATE POLICY settings_delete_own ON qadaa.settings
  FOR DELETE USING (user_id = (select auth.uid()));

ALTER TABLE qadaa.prayer_times ENABLE ROW LEVEL SECURITY;
CREATE POLICY prayer_times_select_all ON qadaa.prayer_times
  FOR SELECT USING (true);

GRANT USAGE ON SCHEMA qadaa TO anon, authenticated, service_role;
GRANT ALL ON ALL TABLES IN SCHEMA qadaa TO authenticated;
GRANT ALL ON ALL TABLES IN SCHEMA qadaa TO service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA qadaa TO service_role;
GRANT SELECT ON qadaa.prayer_times TO anon;
GRANT SELECT ON qadaa.prayer_logs TO anon;
GRANT EXECUTE ON FUNCTION qadaa.get_prayer_times_cached TO anon, authenticated, service_role;
