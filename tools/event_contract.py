#!/usr/bin/env python3
"""Validate public contract 0.2 JSON/JSONL files against local schemas."""
import argparse
import json
import math
import sys
from datetime import datetime
from pathlib import Path
from jsonschema import Draft202012Validator, FormatChecker

ROOT = Path(__file__).resolve().parents[1]
CHECKER = FormatChecker()

@CHECKER.checks("date-time", raises=(ValueError, OverflowError))
def timestamp(value):
    if not isinstance(value, str):
        return True
    parsed = datetime.fromisoformat(value.replace("Z", "+00:00"))
    return parsed.tzinfo is not None

SCHEMAS = {}
for kind in ["asset", "alarm", "telemetry"]:
    schema = json.loads((ROOT / f"schemas/{kind}_event.schema.json").read_text(encoding="utf-8"))
    Draft202012Validator.check_schema(schema)
    SCHEMAS[kind] = Draft202012Validator(schema, format_checker=CHECKER)

def finite(value):
    if isinstance(value, str):
        try:
            value.encode("utf-8")
            return True
        except UnicodeEncodeError:
            return False
    if isinstance(value, float):
        return math.isfinite(value)
    if isinstance(value, dict):
        return all(isinstance(key, str) and finite(key) and finite(item) for key,item in value.items())
    if isinstance(value, list):
        return all(finite(item) for item in value)
    return True

def validate(event):
    if not isinstance(event, dict) or not isinstance(event.get("type"), str) or event["type"] not in SCHEMAS:
        raise ValueError("event must be an object with a supported type")
    if not finite(event):
        raise ValueError("non-finite numbers or invalid UTF-8 are not JSON data")
    errors = sorted(SCHEMAS[event["type"]].iter_errors(event), key=lambda e:str(list(e.path)))
    if errors:
        raise ValueError("; ".join(f"{list(e.path)}: {e.message}" for e in errors))
    return event

def load(path):
    text = Path(path).read_text(encoding="utf-8")
    if Path(path).suffix == ".jsonl":
        return [json.loads(line) for line in text.splitlines() if line.strip()]
    data = json.loads(text)
    return data if isinstance(data, list) else [data]

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("files", nargs="+")
    args = parser.parse_args()
    count = 0
    for path in args.files:
        for index, event in enumerate(load(path), 1):
            try:
                validate(event)
            except ValueError as error:
                raise ValueError(f"{path}:{index}: {error}") from error
            count += 1
    print(f"Validated {count} events", file=sys.stderr)

if __name__ == "__main__":
    try:
        main()
    except (ValueError, OSError) as error:
        print(error, file=sys.stderr)
        sys.exit(1)
