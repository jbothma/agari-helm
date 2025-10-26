#!/bin/bash
set -e

echo "===================================="
echo "Running integration tests"
echo "===================================="

# Test Keycloak authentication
echo ""
echo "Testing Keycloak authentication as system-admin..."
RESPONSE=$(curl --silent --request POST \
  --url http://keycloak.local/realms/agari/protocol/openid-connect/token \
  --header 'content-type: application/x-www-form-urlencoded' \
  --data username=system.admin@agari.tech \
  --data password=pass123 \
  --data grant_type=password \
  --data client_id=dms \
  --data client_secret=VDyLEjGR3xDQvoQlrHq5AB6OwbW0Refc)

SYSADMIN_ACCESS_TOKEN=$(echo "$RESPONSE" | jq -r '.access_token')

if [ "$SYSADMIN_ACCESS_TOKEN" = "null" ] || [ -z "$SYSADMIN_ACCESS_TOKEN" ]; then
  echo "Failed to get access token"
  echo "Response: $RESPONSE"
  exit 1
fi

echo "Successfully obtained access token for system-admin"
echo "Access token (first 50 chars): ${SYSADMIN_ACCESS_TOKEN:0:50}..."

echo ""
echo "===================================="
echo "All tests passed successfully!"
echo "===================================="
