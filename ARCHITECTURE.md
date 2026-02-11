# Architecture (Odds Pipeline)

This repo is a small ingestion + normalization + storage system:

- **Bookmaker scrapers** (brittle, upstream-dependent) live in:
  - `fortuna-sk-scraper/`
  - `chance-sk-scaper/`
  - `synottip-sk-scraper/`
- **Pipeline** (normalization/validation/storage) lives in `pipeline/`.

Primary goal: `python -m pipeline.run_ingest --all` reliably produces validated `NormalizedOdds` rows in SQLite, and records failures per bookmaker without breaking other books.

## High-level data flow

For each bookmaker run:

1. `pipeline.run_ingest.ingest_one()` creates a `fetch_runs` row with `status=running`.
2. `pipeline.mappers.<book>.fetch_raw()` calls the existing scraper code in-process (no HTTP server).
3. Raw payload is persisted to `raw_blobs` (truncated with a clear marker if huge).
4. `pipeline.mappers.<book>.map_raw()` converts raw → list[`pipeline.models.NormalizedOdds`].
5. Normalized rows are validated (`NormalizedOdds.validate()`) and inserted into `odds_snapshot`.
6. `fetch_runs` is finalized with `status=ok|failed`, counts, and duration.

## Extractors (entrypoints + shapes)

Pipeline entrypoints are the adapter functions below (these are the only functions `run_ingest` calls):

- `pipeline/mappers/fortuna.py`
  - Entry: `fetch_raw(sports=[...]) -> dict`
  - Source: `fortuna_scraper.api.FortunaService.fetch_prematch_odds()`
  - Expected raw keys: `records` (list[dict]), `scraped_at_utc`, `bookmaker`, ...
- `pipeline/mappers/chance.py`
  - Entry: `fetch_raw() -> dict`
  - Source: `chance_sk_unofficial.chance_offer_api.ChanceOfferApi.fetch_prematch_football_odds()`
  - Expected raw keys: `odds` (list[dict]), `scraped_at_utc`, `bookmaker`, ...
- `pipeline/mappers/synot.py`
  - Entry: `fetch_raw() -> dict`
  - Source: `synottip_api.synottip.upstream.SynottipUpstream`
  - Expected raw keys: `odds` (list[dict]), `scraped_at_utc`, `meta.pages_fetched`, ...

For a detailed extractor report, see `pipeline/EXTRACTORS_REPORT.py`.

## Pipeline stages and failure boundaries

Failure boundaries are intentionally per-bookmaker:

- `--all` continues even if one bookmaker fails.
- A bookmaker run is marked failed by updating `fetch_runs.status=failed` and storing `fetch_runs.error`.

SQLite atomicity:

- Raw persistence uses a single DB transaction (`INSERT raw_blobs`).
- Normalized insert + final run update (`INSERT odds_snapshot` + `UPDATE fetch_runs`) happen in a single DB transaction.
- If normalization or insert fails, no partial normalized rows are committed for that run.

## Correctness contracts

Normalized schema is `pipeline.models.NormalizedOdds`:

- Required fields must exist and be non-empty (`book`, `sport`, `source_event_id`, `home_raw`, `away_raw`, `market`, `selection`, `raw_hash`, ...).
- `odds_decimal` is `float`, finite, and strictly `> 1.0`.
- Timestamps are tz-aware UTC.
- Home/away sanity: when both explicit home/away fields and `event_name` exist, the pipeline fails fast if they appear swapped.

## Running

Ingest all:

`python -m pipeline.run_ingest --all`

Ingest one bookmaker:

`python -m pipeline.run_ingest --book fortuna`

Offline debugging (no live endpoints):

`python -m pipeline.run_ingest --all --use-sample`

Export latest rows:

`python -m pipeline.export_debug --limit 500`

## Debugging a failure

When a bookmaker fails:

- Check `fetch_runs` for `status=failed`, `error`, `duration_seconds`, counts.
- Raw payloads (possibly truncated) are in `raw_blobs` keyed by `(book, fetched_at)`.
- Structured JSON logs include `book` and `run_id` for correlation.

Useful env vars:

- `PIPELINE_LOG_LEVEL` (default `INFO`)
- `PIPELINE_EXTRACTOR_MAX_ATTEMPTS` (default `3`)
- `PIPELINE_DB_PATH` (default `data/odds.db`)

