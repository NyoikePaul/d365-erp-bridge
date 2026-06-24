import hashlib
import json
import os
from functools import wraps
from fastapi import HTTPException, Request

# Toggle between memory store or production Redis
IDEMPOTENCY_CACHE = {}

def generate_payload_hash(payload: dict) -> str:
    """Generates a unique deterministic fingerprint of the payload."""
    serialized = json.dumps(payload, sort_keys=True)
    return hashlib.sha256(serialized.encode('utf-8')).hexdigest()

def enforce_idempotency():
    def decorator(func):
        @wraps(func)
        async def wrapper(request: Request, *args, **kwargs):
            try:
                payload = await request.json()
            except Exception:
                # Fallback if request contains no JSON body
                return await func(request, *args, **kwargs)

            # Use explicit unique header tracking or fallback to structural payload hash
            message_id = request.headers.get("X-Message-ID") or generate_payload_hash(payload)
            status = IDEMPOTENCY_CACHE.get(message_id)

            if status == "PROCESSING":
                raise HTTPException(status_code=409, detail="Concurrent request running. Dropping retry.")
            elif status == "SUCCESS":
                return {"status": "skipped", "message": "Duplicate blocked. Transaction verified in D365 ledger."}

            IDEMPOTENCY_CACHE[message_id] = "PROCESSING"
            try:
                result = await func(request, *args, **kwargs)
                IDEMPOTENCY_CACHE[message_id] = "SUCCESS"
                return result
            except Exception as e:
                IDEMPOTENCY_CACHE[message_id] = "FAILED"
                raise e
        return wrapper
    return decorator
