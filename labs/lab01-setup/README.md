# Lab 01 — Environment Setup & Hello World

## What You'll Learn
- What uv is and why it's better than pip/venv
- How to scaffold a FastAPI project
- How to scaffold a React project with Vite
- How to run both servers simultaneously

## Background

### What is uv?

`uv` is a modern Python package manager that replaces `pip` + `venv`. It's significantly faster and handles virtual environments automatically.

| Old way | uv way |
|---------|--------|
| `python -m venv .venv` | (automatic) |
| `source .venv/bin/activate` | (automatic) |
| `pip install fastapi` | `uv add fastapi` |
| `python main.py` | `uv run python main.py` |

### What is FastAPI?

FastAPI is a modern Python web framework for building APIs. It automatically generates interactive API documentation (Swagger UI) and uses Python type hints for validation. When you run a FastAPI app, it starts an HTTP server on a port (default: 8000).

### What is Vite?

Vite is a frontend build tool. `npm create vite@latest` scaffolds a React project with hot module replacement — your browser updates instantly as you save files. The dev server runs on port 5173 by default.

## Project Structure

By the end of this lab, your folder structure should look like:

```
fastapi-react-tutorial/       ← repo root (you cloned this)
└── budget-tracker/           ← you create this here
    ├── backend/
    │   ├── pyproject.toml   ← created by uv init
    │   ├── main.py          ← you create this
    │   └── .venv/           ← created automatically by uv
    └── frontend/
        ├── package.json
        ├── index.html
        └── src/
            └── App.jsx
```

## Step-by-Step Guide

### 1. Install uv

`uv` is a global tool — install it once for your whole machine:

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

Restart your terminal after installing. Verify: `uv --version`

> `uv` itself is installed globally (`~/.local/bin/uv`). The `.venv/` virtual environment it creates lives inside your project folder.

### 2. Set up the backend

**Run these commands from the repo root** (the `fastapi-react-tutorial/` directory):

```bash
mkdir budget-tracker && cd budget-tracker
mkdir backend && cd backend
uv init
uv add fastapi uvicorn
```

`uv init` creates a `pyproject.toml` and a sample `hello.py`. You can delete `hello.py`.

### 3. Create your FastAPI app

Create `backend/main.py`. A minimal FastAPI app looks like:

```python
from fastapi import FastAPI

app = FastAPI()

@app.get("/your-route")
def your_handler():
    return {"key": "value"}
```

To run the server:
```bash
uv run uvicorn main:app --reload
```

`--reload` means the server restarts automatically when you save files.

### 4. Set up the frontend

Open a **new terminal tab**, navigate to `budget-tracker/` inside the repo:

```bash
cd fastapi-react-tutorial/budget-tracker
mkdir frontend && cd frontend
npm create vite@latest . -- --template react
npm install
npm run dev
```

The `.` means scaffold in the current directory. When prompted, select **React** (not React + TypeScript).

## Running Both Servers

Keep two terminal tabs open — one for the backend, one for the frontend. You'll do this for every lab.

## Tips

- Swagger UI is at `http://localhost:8000/docs` — use it to test your API without curl
- If port 8000 is taken: `uv run uvicorn main:app --reload --port 8001`
- `uv run` automatically activates the virtual environment — no need to run `source .venv/bin/activate`
- All subsequent lab scripts assume `budget-tracker/` lives inside the repo root

---

> 💬 **Stuck?** Not sure how to do something, or seeing a weird error you don't understand? Just ask me — no question is too small for this tutorial.
