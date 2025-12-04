-- Supabase/Postgres schema for AtividadeSpeakUp

-- Profiles
CREATE TABLE IF NOT EXISTS profiles (
  id TEXT PRIMARY KEY,
  name TEXT,
  email TEXT,
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Modules
CREATE TABLE IF NOT EXISTS modules (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT,
  languageId TEXT,
  "order" INTEGER DEFAULT 0
);

-- Lessons
CREATE TABLE IF NOT EXISTS lessons (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  subtitle TEXT,
  languageId TEXT,
  moduleId TEXT REFERENCES modules(id) ON DELETE SET NULL,
  "order" INTEGER DEFAULT 0
);

-- Phrases
CREATE TABLE IF NOT EXISTS phrases (
  id TEXT PRIMARY KEY,
  text TEXT NOT NULL,
  lessonId TEXT REFERENCES lessons(id) ON DELETE CASCADE
);

-- Notices
CREATE TABLE IF NOT EXISTS notices (
  id TEXT PRIMARY KEY,
  title TEXT,
  language TEXT,
  description TEXT,
  date TIMESTAMPTZ DEFAULT NOW()
);

-- Daily Challenges
CREATE TABLE IF NOT EXISTS daily_challenges (
  id TEXT PRIMARY KEY,
  date DATE,
  dateStr TEXT,
  title TEXT,
  phraseIds JSONB,
  xpBonus INTEGER DEFAULT 0
);

-- User Progress
CREATE TABLE IF NOT EXISTS user_progress (
  userId TEXT PRIMARY KEY,
  totalXp INTEGER DEFAULT 0,
  currentStreak INTEGER DEFAULT 0,
  lastPracticeDate TIMESTAMPTZ,
  completedLessonIds JSONB,
  achievedAchievementIds JSONB,
  completedChallengeIds JSONB
);

-- Vocabulary
CREATE TABLE IF NOT EXISTS vocabulary (
  id TEXT PRIMARY KEY,
  userId TEXT,
  word TEXT NOT NULL,
  translation TEXT,
  originalPhraseId TEXT,
  audioUrl TEXT
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_modules_languageId ON modules(languageId);
CREATE INDEX IF NOT EXISTS idx_lessons_moduleId ON lessons(moduleId);
CREATE INDEX IF NOT EXISTS idx_phrases_lessonId ON phrases(lessonId);
CREATE INDEX IF NOT EXISTS idx_notices_date ON notices(date DESC);
CREATE INDEX IF NOT EXISTS idx_daily_challenges_date ON daily_challenges(date);
CREATE INDEX IF NOT EXISTS idx_user_progress_userId ON user_progress(userId);
