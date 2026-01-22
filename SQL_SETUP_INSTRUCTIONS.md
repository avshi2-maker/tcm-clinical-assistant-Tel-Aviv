# 📊 Database Setup Instructions

## Step 1: Open SQL Editor

Go to this URL:
https://supabase.com/dashboard/project/iqfglrwjemogoycbzltt/sql/new

## Step 2: Copy the Entire Schema

The complete SQL schema is in: `database/supabase-schema.sql`

Or open this file from your downloads and copy everything.

## Step 3: Paste and Run

1. Paste the entire SQL script into the editor
2. Click the green "RUN" button (or press Ctrl+Enter)
3. Wait for "Success" message

## What This Creates:

✅ Tables:
- acupuncture_points (for 361 points)
- zangfu_syndromes (for 87+ syndromes)
- tcm_documents (general content)

✅ Vector Search Functions:
- match_acupuncture_points()
- match_syndromes()
- hybrid_search_points()

✅ Indexes:
- HNSW indexes for fast vector search
- GIN indexes for Hebrew full-text search
- B-tree indexes for exact matches

✅ Security:
- Row Level Security (RLS) enabled
- Public read access
- Service role write access

✅ Sample Data:
- 2 example acupuncture points (LI-4, ST-36)

## Expected Result:

You should see:
```
Success. No rows returned
```

This means all tables, functions, and indexes were created successfully!

## Step 4: Verify Tables Were Created

After running, go to:
https://supabase.com/dashboard/project/iqfglrwjemogoycbzltt/editor

You should see:
- acupuncture_points (with 2 sample rows)
- zangfu_syndromes (empty, ready for data)
- tcm_documents (empty, ready for data)

## Next Step:

Once you confirm the tables are created, we'll process your documents!

---

**Take a screenshot of the success message and show me!** 📸
