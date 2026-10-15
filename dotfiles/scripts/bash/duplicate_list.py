#!/usr/bin/env python3
import hashlib
from collections import defaultdict
from pathlib import Path


def calculate_sha256(filepath: Path, chunk_size: int = 65536) -> str:
    """Compute the SHA-256 hash of a file by streaming chunks."""
    hasher = hashlib.sha256()
    with open(filepath, "rb") as f:
        while chunk := f.read(chunk_size):
            hasher.update(chunk)
    return hasher.hexdigest()


def find_and_filter_duplicates(
    target_dir: str,
    all_hashes_file: str = "all_hashes.txt",
    duplicates_file: str = "duplicates_only.txt",
):
    root_path = Path(target_dir).resolve()
    hash_map = defaultdict(list)

    print(f"Scanning files in: {root_path}...")

    # 1. Compute SHA-256 for every file and store in all_hashes.txt
    with open(all_hashes_file, "w", encoding="utf-8") as all_out:
        for path in root_path.rglob("*"):
            if path.is_file():
                try:
                    file_hash = calculate_sha256(path)
                    entry = f"{file_hash}  {path}\n"
                    all_out.write(entry)
                    hash_map[file_hash].append(str(path))
                except (PermissionError, OSError) as e:
                    print(f"Skipping {path}: {e}")

    print(f"Completed initial scan. All hashes written to '{all_hashes_file}'.")

    # 2. Filter out non-duplicates; write only duplicates (both/all copies)
    duplicate_count = 0
    with open(duplicates_file, "w", encoding="utf-8") as dup_out:
        for file_hash, file_paths in hash_map.items():
            if len(file_paths) > 1:
                dup_out.write(f"Hash: {file_hash} (Count: {len(file_paths)})\n")
                for path in file_paths:
                    dup_out.write(f"  {file_hash}  {path}\n")
                dup_out.write("\n")
                duplicate_count += 1

    print(f"Found {duplicate_count} sets of duplicate files.")
    print(f"Duplicates written to '{duplicates_file}'.")


if __name__ == "__main__":
    # Change "." to any directory path you want to scan
    SCAN_DIRECTORY = "."
    find_and_filter_duplicates(SCAN_DIRECTORY)
