#!/bin/bash
set -e

echo "===================================="
echo "Running integration tests"
echo "===================================="

# Test Keycloak authentication
echo ""
echo "Testing Keycloak authentication as system-admin..."
RESPONSE=$(curl --silent --fail-with-body --request POST \
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

# Test Folio - Create pathogen
echo ""
echo "Testing Folio - Creating pathogen..."
PATHOGEN_RESPONSE=$(curl --silent --fail-with-body --request POST \
  --url http://folio.local/pathogens \
  --header "authorization: Bearer ${SYSADMIN_ACCESS_TOKEN}" \
  --header 'content-type: application/json' \
  --data '{"name": "Test Cholera","description": "Test Cholera Virus","scientific_name": "Vibrio cholerae"}')

PATHOGEN_ID=$(echo "$PATHOGEN_RESPONSE" | jq -r '.pathogen.id')

if [ "$PATHOGEN_ID" = "null" ] || [ -z "$PATHOGEN_ID" ]; then
  echo "Failed to create pathogen"
  echo "Response: $PATHOGEN_RESPONSE"
  exit 1
fi

echo "Successfully created pathogen with ID: ${PATHOGEN_ID}"

# Test Folio - Create project
echo ""
echo "Testing Folio - Creating project..."
PROJECT_RESPONSE=$(curl --silent --fail-with-body --request POST \
  --url http://folio.local/projects \
  --header "authorization: Bearer ${SYSADMIN_ACCESS_TOKEN}" \
  --header 'content-type: application/json' \
  --data "{\"name\": \"Test Cholera Project\",\"description\": \"Test project for cholera research\",\"pathogen_id\": \"${PATHOGEN_ID}\",\"privacy\": \"public\"}")

PROJECT_ID=$(echo "$PROJECT_RESPONSE" | jq -r '.project.id')

if [ "$PROJECT_ID" = "null" ] || [ -z "$PROJECT_ID" ]; then
  echo "Failed to create project"
  echo "Response: $PROJECT_RESPONSE"
  exit 1
fi

echo "Successfully created project with ID: ${PROJECT_ID}"

# Test Folio - Create study
echo ""
echo "Testing Folio - Creating study..."
STUDY_RESPONSE=$(curl --silent --fail-with-body --request POST \
  --url http://folio.local/studies/ \
  --header "authorization: Bearer ${SYSADMIN_ACCESS_TOKEN}" \
  --header 'content-type: application/json' \
  --data "{\"studyId\": \"test-study-001\",\"name\": \"AGARI Test Study\",\"description\": \"Test study for genomic data workflow\",\"projectId\": \"${PROJECT_ID}\",\"info\": {\"projectType\": \"genomics\",\"region\": \"South Africa\"}}")

STUDY_ID=$(echo "$STUDY_RESPONSE" | jq -r '.study.id')

if [ "$STUDY_ID" = "null" ] || [ -z "$STUDY_ID" ]; then
  echo "Failed to create study"
  echo "Response: $STUDY_RESPONSE"
  exit 1
fi

echo "Successfully created study with ID: ${STUDY_ID}"

echo ""
echo "===================================="
echo "All tests passed successfully!"
echo "===================================="
