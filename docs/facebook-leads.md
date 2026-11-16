# Facebook / Instagram lead forms into M71

## Connecting

Sub-account **Settings → Integrations → Facebook → Connect**. Log in, tick only the client's page, enable
"new leads" sync, then **Configure field mapping**. Each lead form on the page gets a **Map Fields** button: map
full name, phone, email and any custom question to an M71 field, confirm, and switch the form on. Save.

## Why leads don't arrive

**An unmapped form is dropped without any error.** Meta's lead-ads testing tool still shows "Success". This is the
first thing to check when leads are missing.

Common ways to end up with an unmapped form:

- A new instant form, including a duplicate of a mapped one, is a new form id and starts unmapped.
- Meta forms can't be edited after publishing, so changing a question means a new form, which means mapping again.
- A custom field created after the mapping page loaded doesn't appear in its dropdown ("no data"). Reload the page.

Map every new form **before** the ad goes live.

Other notes:

- In the mapping dropdown, search built-in fields by their English key (`phone`, `full`, `email`); custom fields
  match by their own name.
- Meta keeps leads readable for 90 days. Older leads can't be pulled from Meta to backfill.

## What arrives on the contact

`GET /contacts/<id>` → `attributionSource`:

- `formId`, `formName`
- `campaignId`, `adSetId`, `adId`, and `utmContent` = the ad name, on real ad leads
- On Meta **test** leads these ad keys are present but `null`
- `createdBy.source` = `INTEGRATION`

## Testing without ad spend

1. Go to <https://developers.facebook.com/tools/lead-ads-testing>, pick the page and the form.
2. Use **Preview form** (not "Create lead", which fills dummy values). It's prefilled with your own name and
   phone and you can edit them.
3. Submit. The contact reaches M71 in under a minute and any workflow on the form trigger runs for real
   (WhatsApp/SMS included).

A second test with the same phone **merges into the existing contact**: tags and fields update, but no new
opportunity is created, and workflows set to "no re-entry" won't fire again. Delete the test contact
(`DELETE /contacts/<id>`) and the test lead in the tool before the next test.

Returning leads from new ads behave the same way: the old opportunity keeps its stage. If those should land back
in "New", add a workflow step that moves them.

## Workflow trigger

The "Facebook Lead Form Submitted" trigger can filter by page and by form ("is any of"). There is no "form is not"
option; to exclude one form, list all the others, and remember to add new forms to that list.

## Backfilling missed leads

1. Export the leads from Meta (Business Suite → leads, or the Graph API `/<formId>/leads`) while they are under
   90 days old.
2. Create each contact with `POST /contacts/` and a tag such as `fb-backfill-2026-11-04`, so the batch can be found.
3. Create an opportunity in the first stage for each (`POST /opportunities/`).
