from fastapi import FastAPI, HTTPException, Depends, status
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from pydantic import BaseModel, validator
from typing import Optional, List
import os
from dotenv import load_dotenv
from supabase import create_client, Client
from passlib.context import CryptContext
from jose import JWTError, jwt
from datetime import datetime, timedelta
import re

load_dotenv()

# Initialize FastAPI App
app = FastAPI(title="TutorConnect API", version="1.0.0")

# Initialize Supabase Client
supabase_url = os.getenv("SUPABASE_DATABASE_URL")
supabase_key = os.getenv("SUPABASE_ANON_KEY")
supabase_client: Client = create_client(supabase_url, supabase_key)

# Password Hashing Context
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# JWT Configuration
supabase_jwt_secret_key= os.getenv("SUPABASE_LEGACY_JWT_SECRET")
algorithm = os.getenv("ALGORITHM", "HS256")
access_token_expire_minutes = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", 30))

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

# --- Pydantic Models (Data Validation) ---

class UserCreate(BaseModel):
    