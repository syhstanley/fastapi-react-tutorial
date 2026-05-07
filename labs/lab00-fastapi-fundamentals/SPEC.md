# Lab 00 — Specification

**This is a reference lab** — no coding required. This document lists key FastAPI patterns and concepts you'll encounter in Labs 01-05.

---

## What You Should Know

### ✅ HTTP Methods
- [ ] Understand the difference between GET, POST, PUT, PATCH, DELETE
- [ ] Know when to use each method
- [ ] Be able to write a route with correct method decorator

### ✅ Path & Query Parameters
- [ ] Know the difference between path parameters (`/users/{id}`) and query parameters (`?limit=10`)
- [ ] Understand type validation (`:int`, `:str`)
- [ ] Know how to provide defaults for query parameters

### ✅ Request/Response Models
- [ ] Create a Pydantic `BaseModel` for request data
- [ ] Create a separate response model with an `id` field
- [ ] Know the `model_dump()` and `from_orm()` methods
- [ ] Understand the `Config` class and `from_attributes = True`

### ✅ Status Codes
- [ ] Know that GET returns 200 (OK)
- [ ] Know that POST returns 201 (Created) or 200 (default)
- [ ] Know that DELETE returns 204 (No Content)
- [ ] Know that 4xx errors (400, 404, 422) indicate client errors
- [ ] Know that 5xx errors indicate server errors

### ✅ Error Handling
- [ ] Be able to raise `HTTPException` with status code and detail
- [ ] Understand 404 (not found) responses
- [ ] Understand 422 (validation error) responses

### ✅ CORS
- [ ] Know why CORS exists (security for cross-origin requests)
- [ ] Know how to enable CORS for frontend on `http://localhost:5173`
- [ ] Know how to use `CORSMiddleware`

### ✅ Database Integration
- [ ] Know how to use `Depends(get_db)` to inject database sessions
- [ ] Know how to query with SQLAlchemy: `db.query(Model).all()`
- [ ] Know how to add records: `db.add()`, `db.commit()`, `db.refresh()`

### ✅ Documentation
- [ ] Know that `/docs` provides Swagger UI (interactive testing)
- [ ] Know that `/redoc` provides ReDoc (documentation view)
- [ ] Know how to test routes using Swagger UI

---

## Key Concepts Checklist

| Concept | You Should Know |
|---------|-----------------|
| **Routes** | How to define routes with `@app.get()`, `@app.post()`, etc. |
| **Path Params** | How to extract dynamic URL segments like `{item_id}` |
| **Query Params** | How to get URL query strings and provide defaults |
| **Request Body** | How to accept JSON with Pydantic models |
| **Response Models** | How to structure and validate API responses |
| **Status Codes** | Which codes to use for different scenarios |
| **Error Handling** | How to raise `HTTPException` for errors |
| **Type Hints** | How Python type hints enable validation and docs |
| **Pydantic** | How to create models and validate data |
| **Async/Await** | When to use `async def` for non-blocking operations |
| **CORS** | Why it matters and how to enable it |
| **Database** | How to integrate with SQLAlchemy |
| **Testing** | How to test with Swagger UI or TestClient |

---

## Example Patterns You'll Use

### Pattern 1: Simple GET
```python
@app.get("/items")
def list_items():
    return []
```

### Pattern 2: GET with ID
```python
@app.get("/items/{item_id}")
def get_item(item_id: int):
    return {"id": item_id}
```

### Pattern 3: GET with Query Params
```python
@app.get("/items")
def list_items(skip: int = 0, limit: int = 10):
    return []
```

### Pattern 4: POST with Body
```python
from pydantic import BaseModel

class ItemCreate(BaseModel):
    name: str
    price: float

@app.post("/items")
def create_item(item: ItemCreate):
    return item
```

### Pattern 5: POST with Database
```python
from sqlalchemy.orm import Session
from fastapi import Depends

@app.post("/items")
def create_item(item: ItemCreate, db: Session = Depends(get_db)):
    db_item = Item(**item.model_dump())
    db.add(db_item)
    db.commit()
    db.refresh(db_item)
    return db_item
```

### Pattern 6: DELETE
```python
from fastapi import HTTPException, status

@app.delete("/items/{item_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_item(item_id: int, db: Session = Depends(get_db)):
    item = db.query(Item).filter(Item.id == item_id).first()
    if not item:
        raise HTTPException(status_code=404, detail="Item not found")
    db.delete(item)
    db.commit()
```

---

## Code You'll Write In Labs

### Lab 01 (Setup)
You'll create a minimal FastAPI app:
```python
from fastapi import FastAPI

app = FastAPI()

@app.get("/health")
def health():
    return {"status": "ok"}
```

### Lab 02 (Routes & Models)
You'll create:
- A Pydantic model for transactions
- GET `/transactions` endpoint
- POST `/transactions` endpoint with validation

### Lab 03 (Database)
You'll modify to use:
- `Depends(get_db)` for database injection
- SQLAlchemy queries
- Database persistence

### Lab 04 (Frontend Integration)
You'll add:
- CORS middleware
- Response models with `response_model=`

### Lab 05 (CRUD)
You'll complete:
- DELETE `/transactions/{id}` endpoint
- 404 error handling

---

## Common Pitfalls to Avoid

❌ **Don't mix path and query parameters**
```python
# Wrong:
@app.get("/items/{skip}?limit=10")

# Right:
@app.get("/items/{item_id}")
def get_items(item_id: int, limit: int = 10):
    pass
```

❌ **Don't forget type hints**
```python
# Wrong:
@app.get("/items/{item_id}")
def get_item(item_id):  # No type hint!

# Right:
@app.get("/items/{item_id}")
def get_item(item_id: int):  # Type hint enables validation
```

❌ **Don't return wrong status codes**
```python
# Wrong:
@app.post("/items")
def create_item(item):
    return item  # Returns 200, should be 201

# Right:
@app.post("/items", status_code=201)
def create_item(item):
    return item
```

❌ **Don't forget CORS for frontend**
```python
# If frontend is at http://localhost:5173 and backend at 8000,
# you MUST enable CORS or requests will fail!

from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:5173"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

❌ **Don't forget `.all()` or `.first()` for queries**
```python
# Wrong:
items = db.query(Item)  # Returns query object, not data!

# Right:
items = db.query(Item).all()  # Returns list
item = db.query(Item).filter(...).first()  # Returns one or None
```

---

## Before You Start Labs 01-05

Make sure you can answer these:

1. **What's the difference between GET and POST?**
   - GET retrieves data, POST creates data

2. **How do you pass data to FastAPI?**
   - Path params: `{item_id}` in URL
   - Query params: `?skip=10` in URL
   - Request body: JSON in POST/PUT body

3. **How does validation work?**
   - Type hints on function parameters
   - Pydantic models for complex data

4. **Why do you need separate request/response models?**
   - Request: what the client sends
   - Response: what the server returns (often includes `id`, timestamps, etc.)

5. **How do you connect to the database?**
   - Use `Depends(get_db)` to inject Session
   - Use `db.query()`, `db.add()`, `db.commit()`

6. **How do you test your API?**
   - Use Swagger UI at `/docs`
   - Use curl from command line
   - Use TestClient in Python tests

---

## Next Steps

✅ Read through this lab carefully
✅ Understand the concepts listed above
✅ Keep the [documentation links](README.md#documentation-links) handy
✅ Start Lab 01 when you're ready!

💡 **Come back to this lab whenever you're confused** — it's your reference guide for the entire tutorial.
