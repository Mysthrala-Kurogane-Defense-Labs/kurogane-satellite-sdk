import json
from pathlib import Path
from event_contract import validate

root = Path(__file__).resolve().parents[1]
cases = json.loads((root / "fixtures/contract_cases.json").read_text(encoding="utf-8"))
for case in cases:
    try:
        validate(case["event"])
        valid = True
    except ValueError:
        valid = False
    assert valid == case["valid"], case["name"]
for path in sorted((root / "fixtures").glob("sample_*.json")):
    validate(json.loads(path.read_text(encoding="utf-8")))
print(f"Validated {len(cases)} positive/negative contract cases and three fixtures")
