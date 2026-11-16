# Authentication

## Base URL

```
https://services.leadconnectorhq.com
```

## Private Integration token (recommended for one sub-account)

Create it in the sub-account under **Settings → Private Integrations**. The token starts with `pit-` and does not
expire on its own; rotate it from the same screen.

Headers on every request:

```
Authorization: Bearer pit-xxxxxxxx
Version: 2021-07-28
Accept: application/json
Content-Type: application/json   (on POST / PUT)
```

The token works from plain curl, from a server, and from a Cloudflare Worker.

The calendars endpoints expect `Version: 2021-04-15`; everything lead-related uses `2021-07-28`.

## Scopes

A token only reaches what its scopes allow. A missing scope returns:

```json
401 {"message": "The token is not authorized for this scope."}
```

For lead work you usually need:

| Scope | For |
|---|---|
| `contacts.readonly` / `contacts.write` | reading, creating and updating contacts, notes, tags |
| `opportunities.readonly` / `opportunities.write` | pipelines, opportunities, moving stages, deleting |
| `conversations.readonly` / `conversations/message.readonly` | checking which messages a lead received |
| `workflows.readonly` | listing workflows |
| `locations/customFields.readonly` / `.write` | listing or creating custom fields |
| `calendars.readonly` | calendars and appointments |

Add a scope later by editing the integration; the token stays the same.

## Agency-level access (many sub-accounts)

For an app that serves several sub-accounts, use OAuth 2.0 through a Marketplace app
(<https://marketplace.gohighlevel.com>). The request shapes in these docs are the same; only the token changes.

## What doesn't work

- The session token the GHL web app uses internally is not meant for scripts. It expires within hours, and calls
  made with it from outside the browser are blocked by Cloudflare (`403`). Use a Private Integration token.
