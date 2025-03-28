-- Create profiles table to extend auth.users
CREATE TABLE IF NOT EXISTS profiles (
  id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  full_name TEXT,
  avatar_url TEXT,
  created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- Create newsletters table
CREATE TABLE IF NOT EXISTS newsletters (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- Create letters table
CREATE TABLE IF NOT EXISTS letters (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  newsletter_id UUID REFERENCES newsletters(id) ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL,
  content JSONB NOT NULL DEFAULT '{}'::jsonb,
  status TEXT NOT NULL DEFAULT 'draft', -- draft, sent
  sent_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- Create subscribers table
CREATE TABLE IF NOT EXISTS subscribers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  newsletter_id UUID REFERENCES newsletters(id) ON DELETE CASCADE NOT NULL,
  email TEXT NOT NULL,
  name TEXT,
  status TEXT NOT NULL DEFAULT 'active', -- active, unsubscribed
  created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
  UNIQUE(newsletter_id, email)
);

-- Create ai_chat_messages table
CREATE TABLE IF NOT EXISTS ai_chat_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  letter_id UUID REFERENCES letters(id) ON DELETE CASCADE NOT NULL,
  role TEXT NOT NULL, -- user, assistant
  content TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- Set up Row Level Security (RLS)
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE newsletters ENABLE ROW LEVEL SECURITY;
ALTER TABLE letters ENABLE ROW LEVEL SECURITY;
ALTER TABLE subscribers ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_chat_messages ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Users can view their own profile" 
  ON profiles FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile" 
  ON profiles FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can view their own newsletters" 
  ON newsletters FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create newsletters" 
  ON newsletters FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own newsletters" 
  ON newsletters FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own newsletters" 
  ON newsletters FOR DELETE USING (auth.uid() = user_id);

CREATE POLICY "Users can view their own letters" 
  ON letters FOR SELECT USING (
    auth.uid() IN (
      SELECT user_id FROM newsletters WHERE id = letters.newsletter_id
    )
  );

CREATE POLICY "Users can create letters" 
  ON letters FOR INSERT WITH CHECK (
    auth.uid() IN (
      SELECT user_id FROM newsletters WHERE id = letters.newsletter_id
    )
  );

CREATE POLICY "Users can update their own letters" 
  ON letters FOR UPDATE USING (
    auth.uid() IN (
      SELECT user_id FROM newsletters WHERE id = letters.newsletter_id
    )
  );

CREATE POLICY "Users can delete their own letters" 
  ON letters FOR DELETE USING (
    auth.uid() IN (
      SELECT user_id FROM newsletters WHERE id = letters.newsletter_id
    )
  );

CREATE POLICY "Users can view their own subscribers" 
  ON subscribers FOR SELECT USING (
    auth.uid() IN (
      SELECT user_id FROM newsletters WHERE id = subscribers.newsletter_id
    )
  );

CREATE POLICY "Users can create subscribers" 
  ON subscribers FOR INSERT WITH CHECK (
    auth.uid() IN (
      SELECT user_id FROM newsletters WHERE id = subscribers.newsletter_id
    )
  );

CREATE POLICY "Users can update their own subscribers" 
  ON subscribers FOR UPDATE USING (
    auth.uid() IN (
      SELECT user_id FROM newsletters WHERE id = subscribers.newsletter_id
    )
  );

CREATE POLICY "Users can delete their own subscribers" 
  ON subscribers FOR DELETE USING (
    auth.uid() IN (
      SELECT user_id FROM newsletters WHERE id = subscribers.newsletter_id
    )
  );

CREATE POLICY "Users can view their own chat messages" 
  ON ai_chat_messages FOR SELECT USING (
    auth.uid() IN (
      SELECT user_id FROM newsletters 
      JOIN letters ON newsletters.id = letters.newsletter_id 
      WHERE letters.id = ai_chat_messages.letter_id
    )
  );

CREATE POLICY "Users can create chat messages" 
  ON ai_chat_messages FOR INSERT WITH CHECK (
    auth.uid() IN (
      SELECT user_id FROM newsletters 
      JOIN letters ON newsletters.id = letters.newsletter_id 
      WHERE letters.id = ai_chat_messages.letter_id
    )
  );

-- Create functions for managing updated_at timestamps
CREATE OR REPLACE FUNCTION update_modified_column() 
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW; 
END;
$$ language 'plpgsql';

-- Create triggers for updated_at timestamps
CREATE TRIGGER update_profiles_modtime 
    BEFORE UPDATE ON profiles 
    FOR EACH ROW EXECUTE PROCEDURE update_modified_column();

CREATE TRIGGER update_newsletters_modtime 
    BEFORE UPDATE ON newsletters 
    FOR EACH ROW EXECUTE PROCEDURE update_modified_column();

CREATE TRIGGER update_letters_modtime 
    BEFORE UPDATE ON letters 
    FOR EACH ROW EXECUTE PROCEDURE update_modified_column();

CREATE TRIGGER update_subscribers_modtime 
    BEFORE UPDATE ON subscribers 
    FOR EACH ROW EXECUTE PROCEDURE update_modified_column();