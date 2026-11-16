#!/usr/bin/env bash
# Lead requests with curl. Set M71_TOKEN (pit-...) and M71_LOCATION first.
# Replace <...> placeholders before running a block.

BASE=https://services.leadconnectorhq.com
H=(-H "Authorization: Bearer $M71_TOKEN" -H "Version: 2021-07-28" -H "Accept: application/json" -H "Content-Type: application/json")

# Pipelines and stage ids
curl -s "${H[@]}" "$BASE/opportunities/pipelines?locationId=$M71_LOCATION"

# Find a contact by phone (+972501234567)
curl -s "${H[@]}" "$BASE/contacts/?locationId=$M71_LOCATION&query=%2B972501234567"

# Create a contact, then an opportunity for it
curl -s "${H[@]}" -X POST "$BASE/contacts/" -d '{
  "locationId": "'"$M71_LOCATION"'",
  "firstName": "Dana", "lastName": "Levi",
  "phone": "+972501234567", "source": "API test", "tags": ["api-test"]
}'

curl -s "${H[@]}" -X POST "$BASE/opportunities/" -d '{
  "locationId": "'"$M71_LOCATION"'",
  "pipelineId": "<pipelineId>", "pipelineStageId": "<stageId>",
  "contactId": "<contactId>", "name": "Dana Levi", "status": "open", "source": "API test"
}'

# Move an opportunity to another stage
curl -s "${H[@]}" -X PUT "$BASE/opportunities/<opportunityId>" -d '{
  "pipelineId": "<pipelineId>", "pipelineStageId": "<newStageId>"
}'

# Open leads still in one stage
curl -s "${H[@]}" -X POST "$BASE/opportunities/search" -d '{
  "locationId": "'"$M71_LOCATION"'", "query": "", "limit": 100,
  "filters": [
    {"field": "status", "operator": "eq", "value": ["open"]},
    {"field": "pipeline_stage_id", "operator": "eq", "value": ["<stageId>"]}
  ]
}'

# Add a note
curl -s "${H[@]}" -X POST "$BASE/contacts/<contactId>/notes" -d '{"body": "Called, no answer"}'
