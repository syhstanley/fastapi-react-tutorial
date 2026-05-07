# Lab 01 — Expected Results

## Backend

With the backend server running, execute:

```bash
curl http://localhost:8000/health
```

Expected output:
```json
{"status":"ok"}
```

Open in browser: `http://localhost:8000/docs`
Expected: Swagger UI loads and shows one endpoint — `GET /health`

## Frontend

Open in browser: `http://localhost:5173`
Expected: Default Vite + React page (shows Vite and React logos with a counter button)

## Checklist

- [ ] `curl http://localhost:8000/health` returns `{"status":"ok"}`
- [ ] Swagger UI loads at `http://localhost:8000/docs`
- [ ] React app loads at `http://localhost:5173`
- [ ] Both servers are running simultaneously
- [ ] `backend/pyproject.toml` exists and lists `fastapi` and `uvicorn` as dependencies
- [ ] Running `uv run uvicorn main:app --reload` starts the server without errors
