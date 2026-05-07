# Lab 08 — Spec

## Feature: Budget Limits

Users want to set monthly spending limits per category to track whether they're staying within their budget.

## Functional Requirements

1. A user can **create** a budget limit: specify a category and a monthly spending limit amount (e.g., "food: $500/month")
2. A user can **view all** budget limits
3. A user can **update** an existing budget limit (change the amount)
4. A user can **delete** a budget limit
5. The **summary endpoint** (`GET /transactions/summary`) must be extended: for each category that has a budget limit set, include the limit amount and the actual spending in the current calendar month

## Data

A budget limit has:
- A unique id
- A category name (text)
- A monthly limit amount (positive number)
- A creation timestamp (auto-set)

## Constraints

- Budget logic must be in a **separate router** from transactions — do not add budget routes to `routers/transactions.py`
- Both routers must be mounted in `main.py`
- Budget data must persist (use the same SQLite database)

## API Design

You decide the endpoint paths, HTTP methods, and request/response shapes. Design them to feel natural and RESTful.

Consider: what would a developer expect these URLs to look like? What HTTP methods make sense for each operation?

## Frontend (Optional)

Adding a UI for budget limits is not required for this lab. The backend is the primary focus.
If you want to go further, add a simple interface for creating and viewing budget limits.
