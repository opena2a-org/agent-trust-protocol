#!/usr/bin/env bash
# ATP Level 1 Conformance Test
# Usage: ./level1.sh https://api.oa2a.org

BASE_URL="${1:?Usage: $0 <authority-url>}"
PASS=0
FAIL=0

test_case() {
  local name="$1" result="$2"
  if [ "$result" = "0" ]; then
    echo "PASS: $name"; ((PASS++))
  else
    echo "FAIL: $name"; ((FAIL++))
  fi
}

# Test 1: Discovery endpoint exists
echo "=== Level 1: Basic Trust ==="

# T1.1: /.well-known/atp returns valid JSON
DISCOVERY=$(curl -sf "$BASE_URL/.well-known/atp")
test_case "Discovery endpoint returns JSON" "$?"

# T1.2: Discovery has required fields
echo "$DISCOVERY" | jq -e '.authorityDid, .version, .endpoints' > /dev/null 2>&1
test_case "Discovery has authorityDid, version, endpoints" "$?"

# T1.3: Discovery has conformance level
echo "$DISCOVERY" | jq -e '.conformanceLevel >= 1' > /dev/null 2>&1
test_case "Conformance level >= 1" "$?"

# T1.4: DID resolution works
DID_ENDPOINT=$(echo "$DISCOVERY" | jq -r '.endpoints.didResolve // "/api/v1/did/{did}"')
# Use registry's own DID
AUTHORITY_DID=$(echo "$DISCOVERY" | jq -r '.authorityDid')
DID_DOC=$(curl -sf "$BASE_URL/api/v1/did/$AUTHORITY_DID")
test_case "DID resolution returns document" "$?"

# T1.5: DID Document has @context
echo "$DID_DOC" | jq -e '.["@context"]' > /dev/null 2>&1
test_case "DID Document has @context" "$?"

# T1.6: DID Document has verificationMethod
echo "$DID_DOC" | jq -e '.verificationMethod | length > 0' > /dev/null 2>&1
test_case "DID Document has verificationMethod" "$?"

# T1.7: Trust proof endpoint works
PROOF_ENDPOINT=$(echo "$DISCOVERY" | jq -r '.endpoints.trustProof // "/api/v1/trust/proof"')
PROOF=$(curl -sf "$BASE_URL$PROOF_ENDPOINT?did=$AUTHORITY_DID")
test_case "Trust proof endpoint returns proof" "$?"

# T1.8: Trust proof has required fields
echo "$PROOF" | jq -e '.did, .trustLevel, .trustScore, .verdict, .issuedAt, .expiresAt, .issuerDid' > /dev/null 2>&1
test_case "Trust proof has all required fields" "$?"

# T1.9: Trust proof has signature
echo "$PROOF" | jq -e '.signatures | length > 0' > /dev/null 2>&1
test_case "Trust proof has at least one signature" "$?"

# T1.10: Trust proof not expired
EXPIRES=$(echo "$PROOF" | jq -r '.expiresAt')
NOW=$(date -u +%Y-%m-%dT%H:%M:%SZ)
[[ "$EXPIRES" > "$NOW" ]]
test_case "Trust proof not expired" "$?"

# T1.11: Trust level is valid (0-4)
LEVEL=$(echo "$PROOF" | jq '.trustLevel')
[[ "$LEVEL" -ge 0 && "$LEVEL" -le 4 ]]
test_case "Trust level is 0-4" "$?"

# T1.12: Trust score is valid (0.0-1.0)
SCORE=$(echo "$PROOF" | jq '.trustScore')
echo "$SCORE" | awk '{exit ($1 >= 0.0 && $1 <= 1.0) ? 0 : 1}'
test_case "Trust score is 0.0-1.0" "$?"

# T1.13: Verify endpoint works
VERIFY=$(curl -sf -X POST "$BASE_URL/api/v1/trust/verify" \
  -H "Content-Type: application/json" \
  -d "$PROOF")
test_case "Verify endpoint accepts proof" "$?"

# T1.14: Verification returns valid=true
echo "$VERIFY" | jq -e '.valid == true' > /dev/null 2>&1
test_case "Verification result is valid=true" "$?"

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
exit $FAIL
