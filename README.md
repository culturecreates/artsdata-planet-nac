# artsdata-planet-nac

National Arts Centre in Ottawa - pipeline to extract JSON-LD from nac-cna.ca into Artsdata

View latest events crawled in Artsdata [here](https://kg.artsdata.ca/query/show?title=Event%20entities%20in%20nac-events%20%284156%20triples%29&sparql=list_events&graph=http://kg.artsdata.ca/culture-creates/artsdata-planet-nac/nac-events)

[2026 NAC Structured Data Report](https://docs.google.com/document/d/1JlaCqIAle4oQ6dFouGUjPIDxBqpUIbNsiDb_cke2EQo/edit?tab=t.0#heading=h.4g15fc6z596y)

## How it works

This planet uses [artsdata-pipeline-action](https://github.com/culturecreates/artsdata-pipeline-action) in `fetch-push` mode. The workflow `.github/workflows/nac-sitemap-entities.yml` runs weekly (Tuesday 04:00 UTC) and on manual dispatch:

1. Reads the English sitemap (`https://nac-cna.ca/en/site/sitemap-ssl`) for `/en/event/{id}` URLs and the French sitemap (`https://nac-cna.ca/fr/site/sitemap-ssl`) for `/fr/event/{id}` URLs
2. Fetches every event page in both languages (`urls-are-entities: "true"`)
3. Saves the result to `output/nac-events.jsonld` in this repo
4. Pushes it to the Artsdata Databus as artifact `nac-events`

Apart from the small shell step that builds the en/fr URL list from the sitemaps, there is no custom scraping code in this repo. To change crawl behaviour, edit that step or the action inputs in the workflow. To test changes without saving or pushing, run the workflow with `mode: fetch-test` (max 5 URLs).

## Secrets

- `PUBLISHER_URI_GREGORY`: Databus publisher URI
- `CLOUDFLARE_PRIVATE_KEY`: optional, signs crawler requests for Cloudflare-protected sites