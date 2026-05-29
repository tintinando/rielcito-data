import json
import hashlib
from datetime import datetime, timezone
from pathlib import Path

DATA_DIR = Path("./data")

manifest = {
    "_comment": "Timestamps en UTC ISO 8601",
    "generatedAt": datetime.now(timezone.utc).isoformat(),
    "files": [],
}

for file in DATA_DIR.glob("*.csv"):
    sha256 = hashlib.sha256(file.read_bytes()).hexdigest()
    manifest["files"].append({"file": file.name, "sha256": sha256})

with open("manifest.json", "w", encoding="utf-8") as f:
    json.dump(manifest, f, indent=2, ensure_ascii=False)
