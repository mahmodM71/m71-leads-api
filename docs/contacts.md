# Contacts

A contact is the person behind the lead. One phone number = one contact (by default a sub-account doesn't allow
duplicate contacts).

## Get one contact

```
GET /contacts/<contactId>
```

Returns `{ contact: { id, firstName, lastName, name, phone, email, tags, source, dateAdded, customFields, attributionSource, ... } }`.

This is the only read that returns **custom field values** and the full **attributionSource**. Search results don't
carry them.

## Find a contact by phone

```
GET /contacts/?locationId=<loc>&query=%2B972501234567
```

Pass the phone in full international form (`+972...`, URL-encoded as `%2B972...`). A local format such as
`050...` finds nothing.

## Search contacts

```
POST /contacts/search
```

```json
{
  "locationId": "<loc>",
  "page": 1,
  "pageLimit": 500,
  "filters": [
    { "field": "date_added", "operator": "range", "value": { "gte": "2026-11-01T00:00:00Z", "lte": "2026-11-16T23:59:59Z" } }
  ],
  "sort": [{ "field": "date_added", "direction": "asc" }]
}
```

Returns `{ total, contacts: [...] }`.

- Date fields are `date_added` and `date_updated`. Writing `dateAdded` returns `422 Invalid field`.
- `pageLimit` goes up to 500. For more, increase `page`.
- Search rows have no `attributionSource` and no custom field values. Fetch `GET /contacts/<id>` for those.
- After a bulk create, tag filters can lag a few seconds behind.

## Create a contact

```
POST /contacts/
```

```json
{
  "locationId": "<loc>",
  "firstName": "Dana",
  "lastName": "Levi",
  "phone": "+972501234567",
  "email": "dana@example.com",
  "source": "Website form",
  "tags": ["new-lead"]
}
```

- `source` is free text; it shows as the "Source" line on the opportunity card.
- If the phone already exists you get `400 "This location does not allow duplicated contacts."` with
  `meta.contactId` of the existing contact. Use that id instead of creating a new one.
- `dateAdded` is rejected (`422 property dateAdded should not exist`). You can't backdate a contact.
- `dnd: true` with `dndSettings: { SMS: {status:"active"}, WhatsApp: {...}, Email: {...}, Call: {...} }` sets
  do-not-disturb per channel.

## Update a contact

```
PUT /contacts/<contactId>
```

```json
{ "source": "Facebook ad", "tags": ["hot"] }
```

## Custom fields

List every custom field (contact and opportunity):

```
GET /locations/<loc>/customFields?model=all
→ { customFields: [{ id, name, model: "contact" | "opportunity", dataType, fieldKey }] }
```

Set a value on a contact:

```json
PUT /contacts/<contactId>
{ "customFields": [{ "id": "<fieldId>", "field_value": "some value" }] }
```

Create a field:

```json
POST /locations/<loc>/customFields
{ "name": "lead_score", "dataType": "NUMERICAL", "model": "contact" }
```

The `fieldKey` is built from the **Latin letters** of the name. A name written only in Hebrew (or any non-Latin
script) gets a key like `contact.__`, and the next such field fails with "already uses this name". Put a Latin word
in the name (`דחיפות - urgency`) or use a lowercase Latin name such as `lead_score`, which is kept as is. If you pass
`fieldKey` yourself it gets prefixed a second time (`contact.x` → `contact.contactx`).

## Notes

```
GET    /contacts/<contactId>/notes            → { notes: [{ id, body, dateAdded }] }
POST   /contacts/<contactId>/notes            { "body": "Called, no answer" }
DELETE /contacts/<contactId>/notes/<noteId>   → { succeeded: true }
```

## Attribution: where the lead came from

`GET /contacts/<id>` → `contact.attributionSource`:

| Key | Meaning |
|---|---|
| `medium` | `facebook` (Messenger / lead form), `whatsapp`, `manual`, `form`, ... |
| `formId`, `formName` | Facebook instant form the lead filled (not in the official schema, but present) |
| `campaignId`, `adSetId`, `adId` | Meta ids; filled on real ad leads, `null` on test leads |
| `utmSource`, `utmMedium`, `utmCampaign`, `utmContent` | from landing-page URLs |
| `fbclid`, `gclid`, `fbc`, `fbp`, `referrer`, `url` | click ids and page info |

`contact.createdBy.source` tells you how it was created (`INTEGRATION` for Facebook forms, `WEB_USER` for manual).

## Delete

```
DELETE /contacts/<contactId>
```
