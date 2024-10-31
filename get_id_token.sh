#!/bin/sh

echo "Get the bao_token of cron-scheduler service"
bao_token=$(sudo cat /tmp/edgex/secrets/support-cron-scheduler/secrets-token.json | jq -r '.auth.client_token')

# Verify bao_token was retrieved
if [ -z "$bao_token" ]; then
  echo "Error: Failed to retrieve bao_token of cron-scheduler service"
  exit 1
fi

echo "Get the id_token of cron-scheduler service"
id_token=$(curl -ks -H "Authorization: Bearer ${bao_token}" "http://localhost:8200/v1/identity/oidc/token/support-cron-scheduler" | jq -r '.data.token')

echo "ID Token of cron-scheduler service: ${id_token}"