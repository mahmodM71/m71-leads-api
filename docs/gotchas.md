# Gotchas

| What you see | Why / what to do |
|---|---|
| `403` from Cloudflare | You're using the web app's session token from outside the browser. Use a Private Integration token. |
| `401 The token is not authorized for this scope.` | Add the scope to the Private Integration. |
| Phone search finds nothing | Use `+972...` (URL-encoded `%2B972...`), not `05...`. |
| `422 Invalid field - dateAdded` | Filters use snake_case: `date_added`, `date_updated`, `last_stage_change_date`, `assigned_to`. |
| `422 property dateAdded should not exist` | You can't backdate contacts or opportunities. Keep the original date in a custom field. |
| `400 This location does not allow duplicated contacts.` | The phone exists; take `meta.contactId` from the error. |
| `400 OPPORTUNITY_NO_DUPLICATE` | The contact already has an opportunity in that pipeline. |
| Opportunity created with `contactId: null` | `POST /opportunities/` accepts a missing or wrong contact id. Validate it first. |
| Search rows have no custom field values or attribution | Fetch `GET /contacts/<id>`. |
| Number custom field reads empty | It's in `fieldValueNumber`. |
| Stage disappeared after a pipeline `PUT` | The stages array replaces the old one. Send every stage with its `id`. |
| `422 property locationId should not exist` on pipeline `PUT` | Put `locationId` in the query string. |
| Second custom field with a Hebrew name fails | The key is built from Latin letters only. Add a Latin word to the name. |
| Facebook leads never show up | The form isn't mapped in Settings → Integrations. See [facebook-leads.md](facebook-leads.md). |
| Test lead didn't trigger the workflow | Same phone as an earlier test merged into the old contact. Delete it and retest. |
| Times look 2–3 hours off | API dates are UTC (`Z`). Convert to the location's timezone. |
| "New" stage count is huge | An import or migration puts every old lead in the first stage with the same `date_added`. Count new leads by `date_added`, not by stage. |
| Tag filter count is short right after a bulk create | The search index lags a few seconds. |
