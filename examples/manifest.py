#!/usr/bin/env python3
"""Read and validate the immutable manifest snapshot."""

import hashlib
import re
import sys
from pathlib import Path


def read_manifest(path, expected_hash=None):
    data = Path(path).read_bytes()
    digest = hashlib.sha256(data).hexdigest()
    if expected_hash is not None and digest != expected_hash:
        raise ValueError("manifest hash mismatch")
    text = data.decode("utf-8")
    if "\r" in text:
        raise ValueError("manifest must use LF line endings")
    lines = text.split("\n")
    if lines[-1] == "":
        lines.pop()
    if not lines or any(not line for line in lines):
        raise ValueError("manifest must contain nonempty lines")
    return lines


def main(args):
    operation, path, *rest = args
    if operation == "count" and not rest:
        print(len(read_manifest(path)))
    elif operation == "hash" and not rest:
        print(hashlib.sha256(Path(path).read_bytes()).hexdigest())
    elif operation == "verify" and len(rest) == 1:
        read_manifest(path, rest[0])
    elif operation == "task" and len(rest) == 2:
        lines = read_manifest(path, rest[0])
        if not re.fullmatch(r"0|[1-9][0-9]*", rest[1]):
            raise ValueError("invalid task ID")
        index = int(rest[1])
        if index >= len(lines):
            raise ValueError("task ID outside manifest")
        print(lines[index])
    else:
        raise ValueError("invalid manifest command")


if __name__ == "__main__":
    try:
        main(sys.argv[1:])
    except (ValueError, OSError, UnicodeError) as error:
        print(f"manifest: {error}", file=sys.stderr)
        sys.exit(1)
