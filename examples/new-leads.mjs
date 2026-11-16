// List leads created in the last N days, with name, phone, stage and source.
// Usage: M71_TOKEN=pit-... M71_LOCATION=... node new-leads.mjs [days]
// Node 18+ (built-in fetch).

const BASE = "https://services.leadconnectorhq.com";
const { M71_TOKEN, M71_LOCATION } = process.env;
const days = Number(process.argv[2] || 7);

if (!M71_TOKEN || !M71_LOCATION) {
  console.error("Set M71_TOKEN and M71_LOCATION");
  process.exit(1);
}

const headers = {
  Authorization: `Bearer ${M71_TOKEN}`,
  Version: "2021-07-28",
  Accept: "application/json",
  "Content-Type": "application/json",
};

async function api(path, options = {}) {
  const res = await fetch(BASE + path, { headers, ...options });
  if (!res.ok) throw new Error(`${res.status} ${path}: ${await res.text()}`);
  return res.json();
}

// Stage id -> stage name
const { pipelines } = await api(`/opportunities/pipelines?locationId=${M71_LOCATION}`);
const stageName = {};
for (const p of pipelines) for (const s of p.stages) stageName[s.id] = `${p.name} / ${s.name}`;

const since = new Date(Date.now() - days * 86400000).toISOString();
const { total, opportunities } = await api("/opportunities/search", {
  method: "POST",
  body: JSON.stringify({
    locationId: M71_LOCATION,
    query: "",
    limit: 100,
    filters: [{ field: "date_added", operator: "range", value: { gte: since } }],
    sort: [{ field: "date_added", direction: "desc" }],
  }),
});

console.log(`${total} leads since ${since}`);
for (const o of opportunities) {
  console.log([o.createdAt, o.contact?.name, o.contact?.phone, stageName[o.pipelineStageId], o.source].join(" | "));
}
