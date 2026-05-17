import os


DATABASE_URL = os.getenv("DATABASE_URL", "sqlite:///./app.db")

JWT_SECRET = os.getenv("JWT_SECRET", "CHANGE_ME_IN_PROD")
JWT_ALG = "HS256"

try:
    ACCESS_TOKEN_MINUTES = int(os.getenv("ACCESS_TOKEN_MINUTES", "60"))
except ValueError:
    ACCESS_TOKEN_MINUTES = 60

UPLOAD_DIR = os.getenv("UPLOAD_DIR", "uploads")

try:
    MAX_UPLOAD_MB = int(os.getenv("MAX_UPLOAD_MB", "50"))
except ValueError:
    MAX_UPLOAD_MB = 50