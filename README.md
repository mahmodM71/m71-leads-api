# M71 API: working with leads

Practical notes for reading and writing leads in M71 through the v2 API.
In M71 a lead is two objects: a **contact** (the person) and an **opportunity** (that person's card on a pipeline
board). Most lead work touches both.

Every request shape here was tested on live sub-accounts between October and November 2026. Where the official
docs and the real responses disagree, these notes follow the real responses.

## Contents

| File | What it covers |
|---|---|
| [docs/auth.md](docs/auth.md) | Private Integration tokens, headers, scopes, base URL |
| [docs/contacts.md](docs/contacts.md) | Create, find, search and update contacts; custom fields; notes; attribution |
| [docs/opportunities.md](docs/opportunities.md) | Pipelines, stages, creating and moving opportunities, search filters |
| [docs/facebook-leads.md](docs/facebook-leads.md) | Facebook / Instagram lead forms into M71, and why leads go missing |
| [docs/conversations.md](docs/conversations.md) | Checking which messages a lead actually got, enrolling a lead in a workflow |
| [docs/gotchas.md](docs/gotchas.md) | Errors, limits and behaviour that surprised us |
| [examples/](examples/) | Runnable curl and Node.js scripts |

## Quick start

1. In the sub-account: **Settings → Private Integrations → Create new integration**. Give it the scopes you need
   (for leads: `contacts.readonly`, `contacts.write`, `opportunities.readonly`, `opportunities.write`).
   Copy the token (`pit-...`).
2. Find the location (sub-account) ID: it's in the URL, `app.m71.co.il/v2/location/<LOCATION_ID>/...`.
3. Call the API:

```bash
export M71_TOKEN="pit-xxxxxxxx"
export M71_LOCATION="your-location-id"

curl -s "https://services.leadconnectorhq.com/opportunities/search?location_id=$M71_LOCATION&limit=20" \
  -H "Authorization: Bearer $M71_TOKEN" \
  -H "Version: 2021-07-28" \
  -H "Accept: application/json"
```

That returns the 20 newest opportunities, each with its contact's name, phone, email and tags.

## Common tasks

| Task | Request |
|---|---|
| New leads since a date | `POST /contacts/search` with a `date_added` range filter ([contacts.md](docs/contacts.md#search-contacts)) |
| Leads still in the first stage | `POST /opportunities/search` filtered by `pipeline_stage_id` ([opportunities.md](docs/opportunities.md#search-opportunities)) |
| Add a lead by hand | `POST /contacts/` then `POST /opportunities/` ([opportunities.md](docs/opportunities.md#create-an-opportunity)) |
| Move a lead to another stage | `PUT /opportunities/<id>` with `pipelineStageId` |
| Which ad / form brought the lead | `GET /contacts/<id>` → `contact.attributionSource` ([contacts.md](docs/contacts.md#attribution-where-the-lead-came-from)) |
| Did the WhatsApp/SMS reach them | `GET /conversations/search?contactId=` then `/conversations/<id>/messages` ([conversations.md](docs/conversations.md)) |

