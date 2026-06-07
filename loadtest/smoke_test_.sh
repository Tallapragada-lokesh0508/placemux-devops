#!/bin/bash
BASE_URL=${1:-http://localhost:3000}

echo "=== PlaceMux Smoke Test ==="

# Test 1: Health check
echo "Testing health endpoint..."
STATUS=$(curl -s -o /dev/null -w '%{http_code}' $BASE_URL/health)
[ $STATUS -eq 200 ] && echo "PASS: Health check" || echo "FAIL: Health check - got $STATUS"

# Test 2: API root
echo "Testing API root..."
STATUS=$(curl -s -o /dev/null -w '%{http_code}' $BASE_URL/)
[ $STATUS -eq 200 ] && echo "PASS: API root" || echo "FAIL: API root - got $STATUS"

echo "=== Smoke Test Complete ==="