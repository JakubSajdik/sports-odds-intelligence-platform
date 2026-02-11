# Contributing

Thanks for taking a look.

## Non-goals / boundaries

- This is analytics/monitoring only.
- No betting automation, no account automation, no anti-bot bypass, no evasion.

## Local dev

### API (FastAPI)

From repo root:

```bash
python -m venv .venv
.\.venv\Scripts\activate
pip install -r api\requirements.txt
python -m api.app
```

### Web (Vite + React)

```bash
cd web
npm install
npm run dev
```

The web dev server proxies `/api/*` to the API on `http://localhost:8000`.

## Lint / format

API:

```bash
python -m ruff check api
python -m ruff format api
```

Web:

```bash
cd web
npm run lint
npm run format
```

