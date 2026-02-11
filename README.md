# Odds Intelligence & Market Monitoring

Portfolio-grade, **read-only** odds analytics over an offline SQLite store:

- Cross-book price comparison (prematch football)
- Best prices per market/outcome
- “Near-arbitrage distance” as a **market inefficiency indicator** (educational monitoring metric)
- No betting automation, no account automation, no anti-bot bypass, no evasion

This repo repackages an existing frozen ingestion pipeline + arbitrage research layer into a product-looking dashboard.

## Quickstart (Docker)

Prereqs: Docker Desktop.

```bash
docker compose up --build
```

- Dashboard: `http://localhost:3000`
- API: `http://localhost:8000/health`

By default, Docker uses `data/demo_odds.db` (small sample DB). You can point to a full DB via `.env`:

```bash
copy .env.example .env
# edit ODDS_DB_PATH to your local DB if desired
docker compose up --build
```

## Local dev (without Docker)

API:

```bash
python -m venv .venv
.\.venv\Scripts\activate
pip install -r api\requirements.txt
python -m api.app
```

Web:

```bash
cd web
npm install
npm run dev
```

Vite proxies `/api/*` to `http://localhost:8000`.

## What’s frozen (do not rewrite)

These components already exist and are treated as **frozen**:

- Scrapers/extractors:
  - `fortuna-sk-scraper/`
  - `chance-sk-scaper/` (folder name as-is)
  - `synottip-sk-scraper/`
- Pipeline: `pipeline/` writes to `data/odds.db` (SQLite), including tables:
  - `fetch_runs`, `raw_blobs`, `odds_snapshot`, `event_map`, `opportunities`
- Arb layer: `arb/` reads DB, matches events, computes best odds, detects arbs

This dashboard/API is **read-only**. It may create **indexes only** (idempotent) for performance.

## Architecture

```
   (frozen)                         (new, read-only)
scrapers/*     --->   pipeline/*  -------------------->  data/odds.db
                                 \
                                  \--> api/ (FastAPI) --> web/ (React)
                                        ^                   |
                                        |                   |
                                   /api/* over HTTP   dashboard UI
```

## UI preview (SVG “screenshots”)

These are lightweight, repo-friendly SVG previews:

- `docs/screenshots/overview.svg`
- `docs/screenshots/events.svg`
- `docs/screenshots/event-details.svg`

![Overview](docs/screenshots/overview.svg)
![Events](docs/screenshots/events.svg)
![Event details](docs/screenshots/event-details.svg)

## How matching works (global_event_id)

Cross-book matching is built in `arb/event_matching.py` (frozen):

- Events are clustered by strict key: `sport + home_norm + away_norm`
- Kickoff times are clustered within a small window
- A deterministic `global_event_id` is computed as:
  - `sha1(sport|home_norm|away_norm|kickoff_rounded_to_5min)`

This is conservative by design: false negatives are acceptable; false positives are not.

## Data model (SQLite)

Key tables:

- `fetch_runs`: ingestion runs per book (status, counts, timings)
- `raw_blobs`: raw JSON payloads (debugging/audit)
- `odds_snapshot`: normalized rows (book, event, market, selection, odds, timestamps)
- `event_map`: cross-book mapping from `(book, source_event_id)` to `global_event_id`
- `opportunities`: detected arbitrage opportunities (research output)

## Near-arbitrage distance (monitoring metric)

For a market with outcomes `i`, take the **best** decimal odds across books per outcome:

```
implied_sum = Σ (1 / best_odds_i)
distance_to_arb = max(0, implied_sum - 1)
```

- `distance_to_arb == 0` means an arbitrage exists (`implied_sum <= 1`)
- Larger values mean “farther from arbitrage”

This is explicitly labeled and used as an **educational market inefficiency indicator**, not an automation feature.

## API overview

FastAPI OpenAPI docs:

- `http://localhost:8000/docs`

Main endpoints:

- `GET /health`
- `GET /books`
- `GET /events?since_minutes=...`
- `GET /odds?event_id=...&market=1X2|OU_2.5`
- `GET /best?since_minutes=...`
- `GET /near_arbs?since_minutes=...&limit=...`

## License

MIT — see `LICENSE`.

