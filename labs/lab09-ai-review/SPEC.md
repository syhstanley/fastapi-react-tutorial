# Lab 09 — Spec

## Your Task

Create a file called `agent.md` in your project root — the `budget-tracker/` folder, not inside `backend/` or `frontend/`.

## Required Sections

Your `agent.md` must contain all five of the following sections. Use Markdown headers to label each section clearly.

---

### Section 1: Project Overview

Describe what this app does and its tech stack in 3–5 sentences. Write it as if you're introducing the project to someone who has never seen it before.

---

### Section 2: Directory Structure

List the key files in your project and what each one does. Focus on the backend. At minimum, describe:
- `main.py`
- `database.py`
- `models.py`
- `schemas.py`
- Each file in `routers/`

---

### Section 3: Coding Conventions

Describe the patterns you consistently followed throughout the project. Examples of things to mention:
- How you manage database sessions (e.g., "I always use `Depends(get_db)` to inject sessions")
- How you structure error handling (e.g., "I raise `HTTPException` with a `detail` message for 404s")
- Any naming conventions (e.g., "Router files are named after the resource they handle")

Be honest — if you were inconsistent somewhere, note it.

---

### Section 4: What to Review

Tell the AI exactly which code to focus on. Name the specific files you created or modified in Lab 08.

---

### Section 5: Review Focus

Ask at least 2 specific questions about your Lab 08 code. These must be specific to your implementation, not generic. Examples:

- "Is my error handling in the budget router consistent with the transactions router?"
- "Are my endpoint paths RESTful? Would another developer expect these URLs?"
- "Is there duplicated logic between the budget router and the transactions router that I should extract?"
- "Is the way I query the current month's spending correct and efficient?"

---

## Then: Run the Review

1. Open [claude.ai](https://claude.ai) (or another AI assistant)
2. Start a new conversation
3. Paste the full contents of your `agent.md`
4. Paste the full contents of your Lab 08 files
5. Send it and read the AI's response

## Requirements

- `agent.md` exists in the project root (`budget-tracker/agent.md`)
- Contains all 5 required sections with meaningful content
- Sections 4 and 5 reference your specific Lab 08 code (not generic placeholders)
- You have received and read the AI's feedback
