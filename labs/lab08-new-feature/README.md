# Lab 08 — New Feature with a Separate Router

## What You'll Learn
- How to structure a growing FastAPI codebase
- How to decide what belongs in which router
- How to design your own API endpoints from requirements

## Background

### Why Split Routers?

In Lab 02, you created `routers/transactions.py`. That works well for a small app, but as you add more features, dumping everything into one file creates problems:

- Hard to find what you're looking for
- Unrelated code is mixed together
- Multiple features compete for changes in the same file

FastAPI's `APIRouter` lets you define feature-specific routers in separate files, each with its own prefix. The key question is: what belongs together?

A good rule of thumb: if you can describe a router's purpose in one sentence without saying "and", it has a focused responsibility.

### This Lab Is Different

Previous labs told you exactly what files to create and where. This lab gives you the functional requirements and lets you decide how to organize your code.

There's no single right answer — but there are better and worse choices. As you design, ask yourself:

- If someone new joined the project today, where would they expect to find budget-related code?
- If this feature grew to 10 endpoints, would your current organization still make sense?
- Is it clear where transactions end and budgets begin?

## Your Task

Read the spec. Design your solution. Build it.
