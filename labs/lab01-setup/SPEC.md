# Lab 01 — Spec

## Backend

1. Create a directory called `backend/` inside a new project folder `budget-tracker/`
2. Initialize a Python project using `uv init`
3. Add the following dependencies using `uv add`:
   - `fastapi`
   - `uvicorn`
4. Create `backend/main.py` with:
   - A FastAPI app instance assigned to a variable called `app`
   - One route: `GET /health` that returns `{"status": "ok"}`
5. Start the server with `uv run uvicorn main:app --reload`

## Frontend

1. Create a directory called `frontend/` inside `budget-tracker/`
2. Initialize a React project using `npm create vite@latest . -- --template react`
3. Install dependencies with `npm install`
4. Start the dev server with `npm run dev`

## Requirements

- Backend must run on `http://localhost:8000`
- Frontend must run on `http://localhost:5173`
- Both servers must be running at the same time (use two terminal tabs)
- Do not modify any frontend files yet — the default Vite + React scaffold is fine for this lab
