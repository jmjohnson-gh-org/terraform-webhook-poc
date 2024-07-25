#!/bin/bash
# Variables
# Read JSON payload from webhook
read -r WEBHOOK_PAYLOAD

# Parse JSON payload to extract values
DEPLOYMENT_ID=$(echo "$WEBHOOK_PAYLOAD" | jq -r '.deployment.id')
ENVIRONMENT_NAME=$(echo "$WEBHOOK_PAYLOAD" | jq -r '.deployment.environment')
REPOSITORY_NAME=$(echo "$WEBHOOK_PAYLOAD" | jq -r '.repository.name')
REPOSITORY_OWNER=$(echo "$WEBHOOK_PAYLOAD" | jq -r '.repository.owner.login')
INSTALLATION_ID=$(echo "$WEBHOOK_PAYLOAD" | jq -r '.installation.id')

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

echo $JWT

echo Auth as GitHub App and get installation access token
INSTALLATION_ACCESS_TOKEN=$(curl -s -X POST \
  -H "Authorization: Bearer $JWT" \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/app/installations/$INSTALLATION_ID/access_tokens | jq -r .token)

echo approve deployment job
curl -X POST \
  -H "Authorization: Bearer $INSTALLATION_ACCESS_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  -d '{"state": "approved"}' \
  https://api.github.com/repos/$REPOSITORY_OWNER/$REPOSITORY_NAME/deployments/$DEPLOYMENT_ID/environments/$ENVIRONMENT_NAME/approval