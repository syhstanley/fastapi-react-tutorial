# Lab 09 — AI Coding Style Review

## What You'll Learn
- What `agent.md` (also called `CLAUDE.md`) is and how AI tools use it
- How to describe your codebase so an AI gives useful, specific feedback
- How to ask precise questions to get precise answers

## Background

### What is agent.md?

AI assistants can give much more targeted code review when they understand the context of your project. `agent.md` is a file you write that explains:

- What the project does
- How it's organized
- The patterns and conventions you use
- What you specifically want reviewed

Without this context, an AI might give generic advice ("use descriptive variable names"). With it, it can point to specific patterns in your code and give actionable feedback.

### Context = Quality

The quality of AI feedback is directly proportional to the quality of context you provide.

**Vague prompt:**
> "Review my code"

**Result:** Generic advice that could apply to any codebase.

**Specific prompt:**
> "Here's my `agent.md` describing my project conventions. Please review `routers/budgets.py` from Lab 08. Specifically: (1) Is my error handling consistent with how I handle errors in `routers/transactions.py`? (2) Are my endpoint paths RESTful — would another developer expect these URLs?"

**Result:** Feedback specific to your code, your patterns, your choices.

### You Don't Have to Agree

The goal of this lab isn't to blindly apply every suggestion an AI makes. It's to think critically about your code by reading an external perspective. Sometimes the AI is right. Sometimes it's wrong or doesn't have enough context. Your job is to evaluate the feedback and decide what to do with it.

## How to Run the Review

1. Write your `agent.md`
2. Open an AI assistant — [Claude](https://claude.ai) is recommended
3. Start a new conversation
4. Paste the contents of `agent.md`
5. Paste the full contents of your Lab 08 files
6. Ask your specific questions
7. Read the response and think critically about it

## Tips

- Be specific — "is my error handling consistent?" gets better results than "review my code"
- Include the actual code, not a description of it
- If the AI's suggestion seems off, ask it to explain its reasoning
- One useful follow-up: "If you had to identify the single most important improvement, what would it be?"
