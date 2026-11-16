# Opportunities and pipelines

An opportunity is a lead's card on a pipeline board. It belongs to one contact, one pipeline and one stage.

## Pipelines and stages

```
GET /opportunities/pipelines?locationId=<loc>
→ { pipelines: [{ id, name, stages: [{ id, name, position }] }] }
```

You need the pipeline id and the stage ids for almost everything else. Stage ids don't change when you rename
or reorder stages.

Create a pipeline:

```json
POST /opportunities/pipelines
{
  "locationId": "<loc>",
  "name": "Leads",
  "stages": [{ "name": "New", "position": 0 }, { "name": "Contacted", "position": 1 }],
  "showInFunnel": true,
  "showInPieChart": true
}
```

Add, rename, reorder or remove stages: send the **whole** stage list back.

```json
PUT /opportunities/pipelines/<pipelineId>?locationId=<loc>
{
  "name": "Leads",
  "stages": [
    { "id": "<existingStageId>", "name": "New", "position": 0 },
    { "id": "<existingStageId>", "name": "Contacted", "position": 1 },
    { "name": "Meeting set", "position": 2 }
  ],
  "showInFunnel": true,
  "showInPieChart": true
}
```

- Keep the `id` on existing stages; a stage sent without an id is treated as a new stage.
- A stage left out of the list is deleted. Check it's empty first, and check no workflow or saved view uses it.
- `locationId` goes in the query string here. In the body it returns `422 property locationId should not exist`.

## Create an opportunity

```json
POST /opportunities/
{
  "locationId": "<loc>",
  "pipelineId": "<pipelineId>",
  "pipelineStageId": "<stageId>",
  "contactId": "<contactId>",
  "name": "Dana Levi",
  "status": "open",
  "source": "Website form",
  "monetaryValue": 0
}
```

- If `contactId` is missing or wrong the call still succeeds and creates an orphan opportunity. Check the id first.
- One contact can have only one opportunity per pipeline.
- Creating 100 contacts plus 100 opportunities in a loop took about 1–2 minutes with no rate-limit errors.

## Move, update, delete

```json
PUT /opportunities/<opportunityId>
{ "pipelineId": "<pipelineId>", "pipelineStageId": "<newStageId>" }
```

- Moving to another pipeline where the contact already has an opportunity returns `400 OPPORTUNITY_NO_DUPLICATE`.
- `status` is one of `open`, `won`, `lost`, `abandoned`.
- `PUT` with the same stage doesn't change `lastStageChangeAt`, so it's a safe write test.

```
DELETE /opportunities/<opportunityId>
```

## Search opportunities

Simple form (query string):

```
GET /opportunities/search?location_id=<loc>&pipeline_id=<pipelineId>&limit=100
GET /opportunities/search?location_id=<loc>&contact_id=<contactId>
```

Pagination: the response has `meta.startAfter` and `meta.startAfterId`; pass them as `startAfter` and
`startAfterId` for the next page.

Full form with filters (this is what the board itself sends):

```json
POST /opportunities/search
{
  "locationId": "<loc>",
  "query": "",
  "limit": 100,
  "filters": [
    { "field": "pipeline_id", "operator": "eq", "value": ["<pipelineId>"] },
    { "field": "status", "operator": "eq", "value": ["open"] },
    { "field": "pipeline_stage_id", "operator": "eq", "value": ["<stageId>"] },
    { "field": "date_added", "operator": "range", "value": { "gte": "2026-11-09T00:00:00Z" } }
  ],
  "sort": [{ "field": "date_added", "direction": "desc" }]
}
```

Returns `{ total, opportunities: [...] }`. Each opportunity includes `contact: { id, name, phone, email, tags }`,
so you don't need a second call for the phone.

### Filter fields that work

| Field | Notes |
|---|---|
| `pipeline_id`, `pipeline_stage_id`, `status` | `operator: "eq"`, value is an array |
| `assigned_to` | `eq` with user ids, or `exists` / `not_exists` (unassigned leads) |
| `contact_id` | that contact's opportunities |
| `date_added`, `date_updated`, `last_stage_change_date` | `operator: "range"`, `{ gte, lte }` ISO dates |
| `custom_fields.<fieldKey without "opportunity.">` or `custom_fields.<fieldId>` | `exists`, `eq` |

Field names are snake_case in filters and camelCase in the response (`assigned_to` vs `assignedTo`). A wrong name
returns `{ message: "Invalid field - assignedTo" }`. `last_stage_change_at` and `updated_at` don't exist as filters.

OR groups go at the top level next to plain filters, which are ANDed:

```json
"filters": [
  { "field": "pipeline_id", "operator": "eq", "value": ["<pipelineId>"] },
  { "group": "OR", "filters": [
    { "field": "date_added", "operator": "range", "value": { "gte": "2026-11-09T00:00:00Z" } },
    { "field": "last_stage_change_date", "operator": "range", "value": { "gte": "2026-11-09T00:00:00Z" } }
  ]}
]
```

## Opportunity object

`id, name, monetaryValue, pipelineId, pipelineStageId, assignedTo, status, source, lostReasonId, contactId,
locationId, customFields, createdAt, updatedAt, lastStageChangeAt, lastStatusChangeAt, contact, attributions`

There is no stage history and no "first contacted at" time. To measure speed-to-lead, have a workflow write a date
custom field when the lead leaves the first stage; past leads can't be measured afterwards.

Number custom fields come back in `customFields[].fieldValueNumber`, not `fieldValue`.

## Lost reasons, custom fields

```
GET /opportunities/lost-reason?locationId=<loc>
GET /locations/<loc>/customFields?model=opportunity
```
