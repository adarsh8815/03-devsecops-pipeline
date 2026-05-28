from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from fastapi.middleware.cors import CORSMiddleware
import jwt
import hashlib
import os
import logging

logging.basicConfig(level=logging.INFO)
log = logging.getLogger(__name__)

app = FastAPI(title="Secure Banking API", version="2.0.0")
security = HTTPBearer()

SECRET_KEY = os.getenv("JWT_SECRET", "change-in-production-use-vault")
ALGORITHM = "HS256"

app.add_middleware(
    CORSMiddleware,
    allow_origins=os.getenv("ALLOWED_ORIGINS", "https://app.mybank.com").split(","),
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT"],
    allow_headers=["*"],
)

def verify_token(credentials: HTTPAuthorizationCredentials = Depends(security)):
    token = credentials.credentials
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        return payload
    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=401, detail="Token expired")
    except jwt.JWTError:
        raise HTTPException(status_code=401, detail="Invalid token")

@app.get("/health")
async def health():
    return {"status": "healthy", "service": "banking-api", "version": "2.0.0"}

@app.get("/api/v1/accounts/{account_id}", dependencies=[Depends(verify_token)])
async def get_account(account_id: str, current_user: dict = Depends(verify_token)):
    if not account_id.isalnum() or len(account_id) > 20:
        raise HTTPException(status_code=400, detail="Invalid account ID format")
    log.info(f"Account {account_id} accessed by user {current_user.get('sub')}")
    return {"account_id": account_id, "balance": 1000.00, "currency": "USD"}

@app.post("/api/v1/transfer", dependencies=[Depends(verify_token)])
async def transfer(from_account: str, to_account: str, amount: float):
    if amount <= 0 or amount > 1000000:
        raise HTTPException(status_code=400, detail="Invalid transfer amount")
    if not from_account.isalnum() or not to_account.isalnum():
        raise HTTPException(status_code=400, detail="Invalid account format")
    log.info(f"Transfer {amount} from {from_account} to {to_account}")
    return {"transaction_id": hashlib.sha256(f"{from_account}{to_account}{amount}".encode()).hexdigest()[:16], "status": "completed"}
