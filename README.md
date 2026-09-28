# artsdata-planet-nac

National Arts Centre in Ottawa - pipeline to extract JSON-LD from nac-cna.ca into Artsdata

View latest events crawled in Artsdata [here](https://kg.artsdata.ca/query/show?title=Event%20entities%20in%20nac-events%20%284156%20triples%29&sparql=list_events&graph=http://kg.artsdata.ca/culture-creates/artsdata-planet-nac/nac-events)

[2026 NAC Structured Data Report](https://docs.google.com/document/d/1JlaCqIAle4oQ6dFouGUjPIDxBqpUIbNsiDb_cke2EQo/edit?tab=t.0#heading=h.4g15fc6z596y)

## How it works

This planet uses [artsdata-pipeline-action](https://github.com/culturecreates/artsdata-pipeline-action) in `fetch-push` mode. The workflow `.github/workflows/nac-events.yml` runs weekly (Tuesday 04:00 UTC) and on manual dispatch:

1. Crawls the NAC sitemap (`https://nac-cna.ca/site/sitemap-ssl`) and extracts event pages matching `/en/event/` and `/fr/event/`
2. Saves the result to `output/nac-events.jsonld` in this repo
3. Pushes it to the Artsdata Databus as artifact `nac-events`

There is no custom scraping code in this repo. To change crawl behaviour, edit the action inputs in the workflow. To test changes without saving or pushing, run the workflow with `mode: fetch-test` (max 5 URLs).

## Secrets

- `PUBLISHER_URI_GREGORY`: Databus publisher URI
- `CLOUDFLARE_PRIVATE_KEY`: optional, signs crawler requests for Cloudflare-protected sites