# TCM Document Processor - Configuration
# Copy this to the same folder as tcm_document_processor.py

# Your Supabase credentials
SUPABASE_URL = "https://iqfglrwjemogoycbzltt.supabase.co"

# Using ANON key - make sure RLS policies allow inserts
SUPABASE_KEY = SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlxZmdscndqZW1vZ295Y2J6bHR0Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2ODU1Mzg4MywiZXhwIjoyMDg0MTI5ODgzfQ.GFIM_DIXaq7y5_uz_UQS6LYtZOzY2M3mzNpQV2WeZ6Q"

# Your document files (exact names from your folder)
ACUPUNCTURE_FILE = r"C:\tcm-clinical-assistant-Tel-Aviv\KNOWLEDGE ACUPUNCTURE POINTS BOOK^MPOINTS CATACORIES.docx"
SYNDROME_FILE = r"C:\tcm-clinical-assistant-Tel-Aviv\zang-fu-syndromes-hebrew.docx"

# Processing options
BATCH_SIZE = 50  # Process 50 items at a time
TRANSLATION_DELAY = 0.1  # Seconds between translations (avoid rate limits)
