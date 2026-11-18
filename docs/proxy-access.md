# Access through the M71 proxy key

Some partners get an **M71 proxy key** instead of a Private Integration token. The proxy is a thin layer in front
of the API: same paths, same request bodies, same responses. Only three things change:

- **Base URL:** `https://m71-leads-api.netlify.app` instead of `https://services.leadconnectorhq.com`
- **Key:** your M71 key (`m71_...`) in `Authorization: Bearer`, not a `pit-...` token
- **Location:** the key works on one sub-account. M71 sends you its location ID together with the key; any other
  `locationId` / `location_id` is refused

Everything else in these docs applies as written.

```bash
export M71_KEY="m71_xxxxxxxx"
export M71_LOCATION="the-location-id-you-were-given"

curl -s "https://m71-leads-api.netlify.app/opportunities/search?location_id=$M71_LOCATION&limit=20" \
  -H "Authorization: Bearer $M71_KEY" \
  -H "Version: 2021-07-28" \
  -H "Accept: application/json"
```

## What the key can do

| Area | Allowed |
|---|---|
| Contacts | `GET /contacts/`, `GET /contacts/<id>`, `POST /contacts/search`, `GET /contacts/search/duplicate`, `POST /contacts/`, `POST /contacts/upsert`, `PUT /contacts/<id>` |
| Notes | `GET /contacts/<id>/notes`, `GET`/`PUT /contacts/<id>/notes/<noteId>`, `POST /contacts/<id>/notes` |
| Tags | `POST` and `DELETE /contacts/<id>/tags` |
| Opportunities | `GET` and `POST /opportunities/search`, `GET /opportunities/<id>`, `POST /opportunities/`, `POST /opportunities/upsert`, `PUT /opportunities/<id>`, `PUT /opportunities/<id>/status` |
| Settings (read only) | `GET /opportunities/pipelines`, `GET /opportunities/lost-reason`, `GET /locations/<loc>/customFields` |

Anything else returns `403` with the method and path that was refused. That includes deleting contacts or
opportunities, adding a contact to a workflow or campaign, conversations and messages, calendars, and changes to
pipelines or custom fields. If you need one of these, ask M71.

## Your changes don't start automations

Leads in this sub-account get automatic WhatsApp messages and reports to Meta when a rep moves them between
stages. Changes made with the proxy key **do not start any of them**: moving a lead to "meeting set" through the
API sends the customer nothing and reports nothing to Meta.

How it works, so you aren't surprised by it:

- Every opportunity write you make (`POST`, `PUT`, upsert, status) also sets the opportunity custom field
  **API change (no automations)** to `api`, in the same request. The stage automations skip opportunities where
  that field has a value.
- About 6 seconds later the proxy clears the field again, so the next move a rep makes in the app runs the
  automations as usual. You'll see that field on the opportunity for those few seconds; don't write to it.
- Contact writes don't start automations either: nothing in this sub-account runs on "contact created" or
  "contact updated".

If you need a message to go out after your change, a rep has to move the lead in the app, or ask M71.

## Errors you may see

| Status | Meaning |
|---|---|
| `401` `Missing or wrong API key` | No `Authorization: Bearer m71_...` header, or the key is wrong or was turned off |
| `403` `... is not allowed with this key` | The endpoint isn't on the list above |
| `403` `locationId must be ...` | The request names a different sub-account |
| anything else | Passed through unchanged from the API; see [gotchas.md](gotchas.md) |

Every write made with the key is logged on M71's side (who, when, path, body, result).
