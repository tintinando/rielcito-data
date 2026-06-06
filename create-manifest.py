#!/usr/bin/env python3
"""
Gestor de Manifest para archivos CSV.

Este script mantiene un archivo manifest.json con información sobre todos los
archivos .csv en el directorio ./data, incluyendo su hash SHA-256 y fecha de
última actualización.

Se utiliza típicamente en flujos de CI/CD o pipelines para detectar cambios
en datos estáticos.
"""

import json, hashlib
from pathlib import Path
from datetime import datetime, timezone
from typing import NotRequired, TypedDict, List


# ==================== CONFIGURACION ====================

DATA_DIR = Path("./data")
MANIFEST_FILE = Path("./manifest.json")

# ==================== TIPOS ====================


class FileRegistry(TypedDict):
    """Registro de cada archivo en el manifest"""

    file: str
    sha256: str
    updatedAt: NotRequired[str]


class ManifestData(TypedDict):
    """Estructura completa del manifest.json"""

    _comment: str
    _comment2: str
    generatedAt: str
    files: List[FileRegistry]


# ==================== MAIN ====================


def main():
    if not DATA_DIR.exists():
        print("Error: el directorio data no existe, nada para hacer")
        return

    manifest_data = load_manifest()

    # crear un índice de búsqueda rápida {"archivo.csv": {...}}
    files_indexed = {reg["file"]: reg for reg in manifest_data["files"]}
    manifest_changed = False

    current_files = list(DATA_DIR.glob("*.csv"))
    current_filenames = {csv_file.name for csv_file in current_files}

    # Actualizar o agregar archivos existentes
    for csv_file in current_files:
        sha256 = calculate_hash(csv_file)
        filename = csv_file.name

        if filename in files_indexed:
            # archivo está en el manifest
            reg_manifest = files_indexed[filename]
            if reg_manifest["sha256"] != sha256:
                reg_manifest["sha256"] = sha256
                reg_manifest["updatedAt"] = now()
                manifest_changed = True
                print(f"Actualizado: {reg_manifest['file']}")
        else:
            # nuevo archivo
            new_registry: FileRegistry = {"file": filename, "sha256": sha256}
            files_indexed[filename] = new_registry
            manifest_changed = True
            print(f"Nuevo: {new_registry['file']}")

    # remover del manifest lo borrado de data
    files_to_keep = []
    for reg in manifest_data["files"]:
        if reg["file"] in current_filenames:
            files_to_keep.append(files_indexed[reg["file"]])
        else:
            manifest_changed = True
            print(f"Eliminado: {reg['file']}")

    if manifest_changed:
        manifest_data["files"] = files_to_keep

        for filename, reg in files_indexed.items():
            if reg not in manifest_data["files"]:
                manifest_data["files"].append(reg)

        manifest_data["generatedAt"] = now()
        save_manifest(manifest_data)


# ==================== HELPERS ====================


def now() -> str:
    """devuelve string de hora en formato ISO UTC con Z"""

    return (
        datetime.now(timezone.utc).isoformat(timespec="seconds").replace("+00:00", "Z")
    )


def calculate_hash(file: Path) -> str:
    """Calcula el hash SHA-256 de un archivo"""
    h = hashlib.sha256()
    with open(file, "rb") as f:
        chunk = 0
        while chunk := f.read(1024):
            h.update(chunk)
    return h.hexdigest()


def load_manifest() -> ManifestData:
    """Carga el manifest, creándolo si no existe"""
    ensure_manifest_exists()

    try:
        with open(MANIFEST_FILE, "r", encoding="utf-8") as f:
            data: ManifestData = json.load(f)

            if not isinstance(data, dict) or "files" not in data:
                raise ValueError("Estructura del manifest inválida")

            return data
    except (json.JSONDecodeError, KeyError, ValueError, TypeError) as e:
        print(f"⚠️ Manifest corrupto o inválido. Se creará uno nuevo. ({e})")
        return get_base_structure()


def ensure_manifest_exists() -> None:
    """Crea el manifest base si no existe"""
    if not MANIFEST_FILE.is_file():
        base = get_base_structure()
        save_manifest(base)


def get_base_structure() -> ManifestData:
    """Devuelve la estructura base del manifest"""

    return {
        "_comment": "Timestamps en UTC ISO 8601",
        "_comment2": "No editar archivo, se genera automáticamente en cada PR",
        "generatedAt": now(),
        "files": [],
    }


def save_manifest(manifest: ManifestData) -> None:
    """Guarda el manifest.json en el disco"""
    temp_file = MANIFEST_FILE.with_suffix(".tmp")

    try:
        with open(temp_file, "w", encoding="utf-8") as f:
            json.dump(manifest, f, indent=4, ensure_ascii=False)

        temp_file.replace(MANIFEST_FILE)
        save_version()
    except Exception as e:
        if temp_file.exists():
            temp_file.unlink()
        raise e


def save_version() -> None:
    with open("version.txt", "w", encoding="utf-8") as f:
        f.write(now())


# ================= EJECUCION =================


if __name__ == "__main__":
    main()
