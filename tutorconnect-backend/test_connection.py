from dotenv import load_dotenv
import os
from supabase import create_client

load_dotenv()

supabase_url = os.getenv("SUPABASE_DATABASE_URL")
supabase_key = os.getenv("SUPABASE_ANON_KEY")

try:
    supabase = create_client(supabase_url, supabase_key)
    response = supabase.table("users").select("*").limit(1).execute()
    print("Connection to Supabase successful!")
    print(f"Table 'users' exists. Found {len(response.data)} records.")
except Exception as e:
    print("Connection to Supabase failed.")
    print(f"Error: {e}")