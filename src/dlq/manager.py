import os
import logging
import hashlib
import json
from datetime import datetime

logger = logging.getLogger("d365_bridge_dlq")
QUARANTINE_DIR = "storage/dlq_quarantine"

# Ensure quarantine directory exists locally
os.makedirs(QUARANTINE_DIR, exist_ok=True)

async def route_to_dlq(payload: dict, error_message: str, destination_entity: str):
    """Isolates poisoned or un-processable financial payloads for manual replay."""
    timestamp = datetime.utcnow().strftime("%Y%m%d_%H%M%S")
    payload_hash = hashlib.md5(json.dumps(payload, sort_keys=True).encode()).hexdigest()[:8]
    
    dlq_filename = f"{QUARANTINE_DIR}/dlq_{destination_entity}_{timestamp}_{payload_hash}.json"
    
    dlq_envelope = {
        "quarantine_meta": {
            "timestamp": datetime.utcnow().isoformat() + "Z",
            "target_entity": destination_entity,
            "failure_reason": error_message
        },
        "payload": payload
    }
    
    with open(dlq_filename, "w") as f:
        json.dump(dlq_envelope, f, indent=4)
        
    logger.critical(f"🚨 [DLQ TRAPPED]: Transaction isolated. File written to: {dlq_filename}")
    return {"status": "quarantined", "reference": dlq_filename}
