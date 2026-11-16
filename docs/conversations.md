# Conversations and workflows for a lead

## Did the lead get our message?

```
GET /conversations/search?locationId=<loc>&contactId=<contactId>
→ conversations[0].id

GET /conversations/<conversationId>/messages?limit=20
→ messages.messages[]: { body, direction, status, dateAdded, meta.error: { code, msg } }
```

`status` is `delivered`, `read`, `failed`, etc. Read failures by `status` and `meta.error.code`, not by
`messageType`, which is sometimes missing. Common WhatsApp failure codes:

| Code | Meaning |
|---|---|
| 131026 | Message undeliverable (number not on WhatsApp, or can't receive) |
| 131049 | Meta held back the marketing message to protect the user's experience |

## Unread conversations

```
GET /conversations/search?locationId=<loc>&status=unread&limit=50
→ conversations[]: { fullName, unreadCount, lastMessageDirection, lastMessageDate (ms), lastMessageType }
```

## Open tasks

```json
POST /locations/<loc>/tasks/search
{ "completed": false, "limit": 50 }
→ tasks[]: { title, dueDate, contactId, contactDetails, assignedToUserDetails }
```

## Add a lead to a workflow

```
POST /contacts/<contactId>/workflow/<workflowId>
{}
→ 201 { succeeded: true }
```

The first step ran within about 20 seconds in our tests.

List workflows (needs `workflows.readonly`):

```
GET /workflows/?locationId=<loc>
```
