# Lab Automation Scripts

This directory contains initialization and verification scripts for each lab in the FastAPI + React tutorial.

## Structure

```
scripts/
├── init/          # Lab initialization scripts
├── verify/        # Lab verification scripts
├── init-all.sh    # Initialize all labs (one-shot)
├── verify-all.sh  # Verify all labs
└── README.md      # This file
```

## Quick Start

### Initialize Individual Lab

```bash
# Lab 01: Environment setup
bash scripts/init/lab01-init.sh

# Lab 02: API routes
bash scripts/init/lab02-init.sh

# Lab 03: Database
bash scripts/init/lab03-init.sh

# Lab 04: React frontend
bash scripts/init/lab04-init.sh

# Lab 05: Full CRUD
bash scripts/init/lab05-init.sh
```

### Verify Individual Lab

```bash
bash scripts/verify/lab01-verify.sh
bash scripts/verify/lab02-verify.sh
bash scripts/verify/lab03-verify.sh
bash scripts/verify/lab04-verify.sh
bash scripts/verify/lab05-verify.sh
```

## What Each Lab Script Does

### Lab 01 (init/lab01-init.sh)
- Creates `budget-tracker/` project directory
- Initializes Python backend with `uv init`
- Installs FastAPI and Uvicorn
- Creates basic `main.py` with `/health` endpoint
- Scaffolds React project with Vite
- Installs npm dependencies

**Time**: ~2-3 minutes

### Lab 02 (init/lab02-init.sh)
- Creates `schemas.py` with Pydantic models
- Creates `routers/` directory structure
- Implements `/transactions` GET and POST endpoints
- Uses in-memory storage (will be replaced with DB in Lab 03)

**Requires**: Lab 01 completed

### Lab 03 (init/lab03-init.sh)
- Adds SQLAlchemy dependency
- Creates `models.py` with Transaction ORM model
- Creates `database.py` with SQLAlchemy setup
- Updates routers to use database persistence
- Creates `.gitignore` for database file

**Requires**: Lab 02 completed
**Creates**: `backend/db/budget.db` (at runtime)

### Lab 04 (init/lab04-init.sh)
- Creates `TransactionList.jsx` React component
- Implements data fetching with `useEffect`
- Updates `App.jsx` to display transactions
- Enables CORS in backend

**Requires**: Lab 03 completed

### Lab 05 (init/lab05-init.sh)
- Creates `TransactionForm.jsx` for adding transactions
- Adds delete button to transaction list
- Implements DELETE endpoint in backend
- Form clears after successful submission

**Requires**: Lab 04 completed

## Verification Scripts

Each verification script checks:

### Lab 01 Verification
- ✓ Directory structure exists
- ✓ `pyproject.toml` configured
- ✓ `main.py` has FastAPI app
- ✓ `package.json` exists

### Lab 02 Verification
- ✓ `schemas.py` with correct Pydantic models
- ✓ `routers/transactions.py` with GET/POST
- ✓ Main app includes router
- ✓ `/transactions` endpoint exists

### Lab 03 Verification
- ✓ `models.py` with ORM definition
- ✓ `database.py` with SQLAlchemy setup
- ✓ Tables created on startup
- ✓ `.gitignore` configured
- ✓ Routers use database dependency

### Lab 04 Verification
- ✓ `TransactionList.jsx` component exists
- ✓ Fetches from `/transactions` API
- ✓ `App.jsx` includes component
- ✓ CORS enabled in backend
- ✓ Empty state message shown

### Lab 05 Verification
- ✓ `TransactionForm.jsx` exists
- ✓ `App.jsx` includes form
- ✓ Delete functionality implemented
- ✓ DELETE endpoint in backend
- ✓ Form clears after submission
- ✓ 404 error handling for delete

## Project Structure After All Labs

```
budget-tracker/
├── backend/
│   ├── .venv/
│   ├── .gitignore
│   ├── db/
│   │   └── budget.db
│   ├── routers/
│   │   ├── __init__.py
│   │   └── transactions.py
│   ├── database.py
│   ├── main.py
│   ├── models.py
│   ├── pyproject.toml
│   └── schemas.py
└── frontend/
    ├── node_modules/
    ├── public/
    ├── src/
    │   ├── App.jsx
    │   ├── App.css
    │   ├── main.jsx
    │   ├── TransactionForm.jsx
    │   ├── TransactionList.jsx
    │   └── index.css
    ├── index.html
    ├── package.json
    └── vite.config.js
```

## Running After Initialization

After initializing a lab, run both servers:

```bash
# Terminal 1 — Backend
cd budget-tracker/backend
uv run uvicorn main:app --reload

# Terminal 2 — Frontend
cd budget-tracker/frontend
npm run dev
```

Then:
- Frontend: http://localhost:5173
- Backend API: http://localhost:8000
- Swagger UI: http://localhost:8000/docs

## Troubleshooting

### "uv: command not found"
The init script attempts to install it automatically. If that fails:
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

### "npm: command not found"
Install Node.js 18+: https://nodejs.org

### Port already in use
Backend: `uv run uvicorn main:app --reload --port 8001`
Frontend: `npm run dev -- --port 5174`

### Database file not created
Lab 03 creates it at startup. Just run the backend server.

## Notes

- These scripts are **idempotent** — they can be run multiple times safely
- They build on each other — do Labs 01-05 in order
- Lab scripts automatically skip Lab 01 if already completed
- Verification scripts are **read-only** — they don't modify code
