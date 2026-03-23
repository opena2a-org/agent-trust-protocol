#!/usr/bin/env bash
# ATP Level 2 Conformance Test (extends Level 1)
# Usage: ./level2.sh https://api.oa2a.org

BASE_URL="${1:?Usage: $0 <authority-url>}"

# Run Level 1 first
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
"$SCRIPT_DIR/level1.sh" "$BASE_URL"
L1_RESULT=$?

PASS=0
FAIL=0

test_case() {
  local name="$1" result="$2"
  if [ "$result" = "0" ]; then echo "PASS: $name"; ((PASS++))
  else echo "FAIL: $name"; ((FAIL++)); fi
}

echo ""
echo "=== Level 2: Auditable Trust ==="

# T2.1: Transparency log endpoint exists
LOG=$(curl -sf "$BASE_URL/api/v1/transparency/trust-proofs?limit=5")
test_case "Transparency log endpoint returns data" "$?"

# T2.2: Log entries have required fields
echo "$LOG" | jq -e '.[0].logIndex' > /dev/null 2>&1 || echo "$LOG" | jq -e '.entries[0]' > /dev/null 2>&1
test_case "Log entries have structure" "$?"

# T2.3: Revocations endpoint exists
REV=$(curl -sf "$BASE_URL/api/v1/trust/revocations?since=2026-01-01T00:00:00Z")
test_case "Revocations endpoint returns data" "$?"

echo ""
echo "=== Level 2 Results: $PASS passed, $FAIL failed ==="
TOTAL_FAIL=$((L1_RESULT + FAIL))
exit $TOTAL_FAIL
