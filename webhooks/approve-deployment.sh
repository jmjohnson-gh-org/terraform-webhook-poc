#!/bin/bash

# Read arguments
DEPLOYMENT_URL=$1
ENVIRONMENT_NAME=$2
INSTALLATION_ID=$3
GITHUB_EVENT=$4

# Debug: Print the extracted values
echo "Deployment URL: $DEPLOYMENT_URL"
echo "Environment Name: $ENVIRONMENT_NAME"
echo "Installation ID: $INSTALLATION_ID"

APP_ID="APP_ID"
PRIVATE_KEY_PATH="/path/to/private-key.pem"

# Generate JWT
echo Generating JWT

# Create JWT header
HEADER=$(echo -n '{"alg":"RS256","typ":"JWT"}' | openssl base64 -e | tr -d '=' | tr '/+' '_-' | tr -d '\n')

# Create JWT payload
NOW=$(date +%s)
IAT=$((NOW - 60))
EXP=$((NOW + 600))
PAYLOAD=$(echo -n "{\"iat\":$IAT,\"exp\":$EXP,\"iss\":\"$APP_ID\"}" | openssl base64 -e | tr -d '=' | tr '/+' '_-' | tr -d '\n')

# Combine header and payload
HEADER_PAYLOAD="$HEADER.$PAYLOAD"

# Sign the JWT
SIGNATURE=$(echo -n "$HEADER_PAYLOAD" | openssl dgst -sha256 -sign $PRIVATE_KEY_PATH | openssl base64 -e | tr -d '=' | tr '/+' '_-' | tr -d '\n')

# Combine header, payload, and signature to form the JWT
JWT="$HEADER_PAYLOAD.$SIGNATURE"

echo
echo $JWT
echo

echo Auth as GitHub App and get installation access token
INSTALLATION_ACCESS_TOKEN=$(curl -s -X POST \
  -H "Authorization: Bearer $JWT" \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/app/installations/$INSTALLATION_ID/access_tokens | jq -r '.token')

echo
echo $INSTALLATION_ACCESS_TOKEN
echo

echo wait...
sleep 15
echo
echo running approval on this url
echo $DEPLOYMENT_URL
echo

echo approving deployment job
curl -L \
  -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $INSTALLATION_ACCESS_TOKEN" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  $DEPLOYMENT_URL \
  -d '{
    "environment_name": "'"$ENVIRONMENT_NAME"'",
    "state": "approved",
    "comment": "LGTM"
  }'

echo
echo deployment job approved!
