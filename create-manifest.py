import json
import hashlib
import os
from datetime import datetime, timezone
from pathlib import Path

DATA_DIR = Path("./data")

changed_files_env = os.environ.get("CHANGED_FILES", "")

changed_filenames = (
    {Path(f).name for f in changed_files_env.split() if f}
    if changed_files_env
    else set()
)

manifest = {
    "_comment": "Timestamps en UTC ISO 8601",
    "_comment2": "No editar archivo, se genera automáticamente en cada PR",
    "generatedAt": datetime.now(timezone.utc).isoformat(),
    "files": [],
}

for file in DATA_DIR.glob("*.csv"):
    sha256 = hashlib.sha256(file.read_bytes()).hexdigest()

    file_entry = {"file": file.name, "sha256": sha256}

    if file.name in changed_filenames:
        file_entry["updatedAt"] = datetime.now(timezone.utc).isoformat()

    manifest["files"].append(file_entry)

with open("manifest.json", "w", encoding="utf-8") as f:
    json.dump(manifest, f, indent=2, ensure_ascii=False)
