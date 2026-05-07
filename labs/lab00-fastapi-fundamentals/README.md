# Lab 00 — FastAPI Fundamentals & Reference

**This is a reference lab** — not a hands-on lab. Read through this before starting Lab 01. It covers FastAPI's core concepts, decorators, and examples you'll use throughout the tutorial.

---

## Table of Contents

1. [What is FastAPI?](#what-is-fastapi)
2. [Installation & Setup](#installation--setup)
3. [Core Concepts](#core-concepts)
4. [HTTP Method Decorators](#http-method-decorators)
5. [Request Parameters](#request-parameters)
6. [Request & Response Models](#request--response-models)
7. [Common Patterns](#common-patterns)
8. [Error Handling](#error-handling)
9. [Testing Your API](#testing-your-api)
10. [Documentation Links](#documentation-links)

---

## What is FastAPI?

FastAPI is a modern Python web framework for building REST APIs. It's:

- **Fast**: One of the fastest Python frameworks (comparable to Go, Node.js)
- **Easy**: Simple syntax with Python type hints
- **Automatic**: Generates interactive API docs (Swagger UI, ReDoc)
- **Standards-based**: Built on OpenAPI and JSON Schema
- **Production-ready**: Includes validation, security, and testing utilities

### Key Features

| Feature | Benefit |
|---------|---------|
| **Type Hints** | Automatic validation and IDE autocomplete |
| **Pydantic Models** | JSON validation and serialization |
| **Automatic Docs** | Interactive Swagger UI at `/docs` |
| **Dependency Injection** | Clean code with `Depends()` |
| **CORS Support** | Cross-origin requests handled easily |
| **WebSockets** | Real-time bidirectional communication |
| **Async/Await** | Non-blocking I/O for better performance |

---

## Installation & Setup

### Install FastAPI and Uvicorn

```bash
# Using uv (recommended)
uv add fastapi uvicorn

# Or using pip
pip install fastapi uvicorn
```

### Minimal App

```python
from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def read_root():
    return {"message": "Hello, World!"}
```

### Run the Server

```bash
# Using uv
uv run uvicorn main:app --reload

# Or using python
python -m uvicorn main:app --reload
```

**Flags:**
- `--reload` — Auto-restart when files change (development only)
- `--host 0.0.0.0` — Listen on all network interfaces
- `--port 8080` — Run on custom port (default: 8000)

### Access Your API

- **Main app**: http://localhost:8000
- **Swagger UI docs**: http://localhost:8000/docs
- **ReDoc docs**: http://localhost:8000/redoc
- **OpenAPI schema**: http://localhost:8000/openapi.json

---

## Core Concepts

### 1. Routes (Endpoints)

A route is a URL path + HTTP method that triggers a function:

```python
@app.get("/users")  # GET /users
def list_users():
    return [{"id": 1, "name": "Alice"}]

@app.post("/users")  # POST /users
def create_user(data: dict):
    return {"id": 2, "name": data["name"]}
```

### 2. Path Parameters

Dynamic parts of the URL:

```python
@app.get("/users/{user_id}")
def get_user(user_id: int):
    # Type hint (int) automatically validates input
    return {"user_id": user_id}

# GET /users/42 → {"user_id": 42}
# GET /users/abc → 422 Validation Error
```

### 3. Query Parameters

URL query string (`?key=value`):

```python
@app.get("/search")
def search(q: str, limit: int = 10, skip: int = 0):
    # q is required, limit defaults to 10
    return {"query": q, "limit": limit, "skip": skip}

# GET /search?q=python → {"query": "python", "limit": 10, "skip": 0}
# GET /search?q=python&limit=20 → {"query": "python", "limit": 20, "skip": 0}
```

### 4. Request Body

JSON data sent in request body (requires Pydantic model):

```python
from pydantic import BaseModel

class User(BaseModel):
    name: str
    email: str
    age: int | None = None

@app.post("/users")
def create_user(user: User):
    return {"created": user.name, "email": user.email}

# POST /users with body:
# {"name": "Alice", "email": "alice@example.com"}
# → {"created": "Alice", "email": "alice@example.com"}
```

### 5. Pydantic Models

Data validation and serialization:

```python
from pydantic import BaseModel

class Item(BaseModel):
    name: str
    price: float
    description: str | None = None
    in_stock: bool = True

# Automatic validation:
# ✅ {"name": "Widget", "price": 9.99}
# ❌ {"name": "Widget", "price": "not a number"} → 422 Error
```

---

## HTTP Method Decorators

### GET — Retrieve Data

```python
@app.get("/items")
def list_items():
    return [{"id": 1, "name": "Item 1"}]

@app.get("/items/{item_id}")
def get_item(item_id: int):
    return {"id": item_id, "name": "Item"}
```

**Use for**: Fetching data, no side effects

---

### POST — Create Data

```python
from pydantic import BaseModel

class ItemCreate(BaseModel):
    name: str
    price: float

@app.post("/items")
def create_item(item: ItemCreate):
    return {"id": 1, "name": item.name, "price": item.price}
```

**Use for**: Creating new resources

---

### PUT — Replace Resource

```python
class ItemUpdate(BaseModel):
    name: str
    price: float

@app.put("/items/{item_id}")
def update_item(item_id: int, item: ItemUpdate):
    return {"id": item_id, "name": item.name, "price": item.price}
```

**Use for**: Replacing entire resource

---

### PATCH — Partial Update

```python
@app.patch("/items/{item_id}")
def partial_update(item_id: int, name: str | None = None):
    # Only update fields that are provided
    return {"id": item_id, "name": name}
```

**Use for**: Updating specific fields

---

### DELETE — Remove Resource

```python
@app.delete("/items/{item_id}")
def delete_item(item_id: int):
    return {"deleted": item_id}
```

**Use for**: Removing resources

---

## Request Parameters

### 1. Path Parameters (Required)

```python
@app.get("/items/{item_id}")
def get_item(item_id: int):
    # Comes from URL path
    return {"item_id": item_id}
```

---

### 2. Query Parameters (Optional)

```python
@app.get("/items")
def list_items(skip: int = 0, limit: int = 10):
    # Comes from URL query string
    return {"skip": skip, "limit": limit}

# GET /items?skip=20&limit=50
```

---

### 3. Request Body (JSON)

```python
from pydantic import BaseModel

class Item(BaseModel):
    name: str
    price: float

@app.post("/items")
def create_item(item: Item):
    # Comes from POST body
    return item
```

---

### 4. Headers

```python
from fastapi import Header

@app.get("/items")
def list_items(x_token: str = Header()):
    # Extract from HTTP headers
    return {"x_token": x_token}

# GET /items with header: X-Token: secret123
```

---

### 5. Cookies

```python
from fastapi import Cookie

@app.get("/items")
def list_items(session_id: str | None = Cookie(default=None)):
    return {"session_id": session_id}
```

---

## Request & Response Models

### Request Model (Pydantic)

```python
from pydantic import BaseModel

class TransactionCreate(BaseModel):
    amount: float
    category: str
    date: str

@app.post("/transactions")
def create_transaction(transaction: TransactionCreate):
    # Validates input against model
    return {"id": 1, **transaction.model_dump()}
```

---

### Response Model

```python
from pydantic import BaseModel

class TransactionResponse(BaseModel):
    id: int
    amount: float
    category: str
    date: str

    class Config:
        from_attributes = True  # Support SQLAlchemy models

@app.post("/transactions", response_model=TransactionResponse)
def create_transaction(transaction: TransactionCreate):
    # Response is validated against TransactionResponse
    return {"id": 1, **transaction.model_dump()}
```

---

### Multiple Response Models

```python
@app.get("/items/{item_id}")
def get_item(item_id: int) -> ItemResponse | None:
    # Return ItemResponse or None
    if item_id == 1:
        return {"id": 1, "name": "Item"}
    return None
```

---

## Common Patterns

### 1. Database Integration

```python
from sqlalchemy.orm import Session
from fastapi import Depends
from database import get_db  # Your DB setup

@app.get("/items")
def list_items(db: Session = Depends(get_db)):
    return db.query(Item).all()
```

---

### 2. Status Codes

```python
from fastapi import status

@app.post("/items", status_code=status.HTTP_201_CREATED)
def create_item(item: Item):
    return item

@app.delete("/items/{item_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_item(item_id: int):
    pass  # 204 returns no content
```

---

### 3. Error Handling

```python
from fastapi import HTTPException

@app.get("/items/{item_id}")
def get_item(item_id: int):
    if item_id == 999:
        raise HTTPException(
            status_code=404,
            detail="Item not found"
        )
    return {"id": item_id}
```

---

### 4. CORS

```python
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:5173"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

---

### 5. Dependency Injection

```python
from fastapi import Depends

def get_query(q: str = ""):
    return q

@app.get("/search")
def search(query: str = Depends(get_query)):
    return {"query": query}
```

---

## Error Handling

### HTTPException

```python
from fastapi import HTTPException

@app.get("/items/{item_id}")
def get_item(item_id: int):
    if item_id < 0:
        raise HTTPException(status_code=400, detail="Invalid ID")
    if item_id > 1000:
        raise HTTPException(status_code=404, detail="Not found")
    return {"id": item_id}
```

### Custom Exception Handlers

```python
@app.exception_handler(ValueError)
async def value_error_handler(request, exc):
    return JSONResponse(
        status_code=400,
        content={"detail": str(exc)},
    )
```

---

## Testing Your API

### Using TestClient

```python
from fastapi.testclient import TestClient

client = TestClient(app)

def test_get_items():
    response = client.get("/items")
    assert response.status_code == 200
    assert response.json() == [...]

def test_create_item():
    response = client.post("/items", json={"name": "Test", "price": 9.99})
    assert response.status_code == 201
```

### Using curl

```bash
# GET
curl http://localhost:8000/items

# POST with JSON body
curl -X POST http://localhost:8000/items \
  -H "Content-Type: application/json" \
  -d '{"name": "Widget", "price": 9.99}'

# DELETE
curl -X DELETE http://localhost:8000/items/1
```

### Using Swagger UI

Visit http://localhost:8000/docs — interactive testing UI built into FastAPI!

---

## Common Decorators Reference

| Decorator | Purpose | Example |
|-----------|---------|---------|
| `@app.get()` | GET request | `@app.get("/items")` |
| `@app.post()` | POST request | `@app.post("/items")` |
| `@app.put()` | PUT request | `@app.put("/items/{id}")` |
| `@app.patch()` | PATCH request | `@app.patch("/items/{id}")` |
| `@app.delete()` | DELETE request | `@app.delete("/items/{id}")` |
| `@app.options()` | OPTIONS request | `@app.options("/items")` |
| `@app.head()` | HEAD request | `@app.head("/items")` |
| `@app.trace()` | TRACE request | `@app.trace("/items")` |

---

## Documentation Links

### 📚 Official FastAPI Documentation
- **Main Site**: https://fastapi.tiangolo.com/
- **GitHub**: https://github.com/tiangolo/fastapi

### 📖 Key Learning Resources

**Getting Started**
- [Tutorial - User Guide](https://fastapi.tiangolo.com/tutorial/)
- [First Steps](https://fastapi.tiangolo.com/tutorial/first-steps/)
- [Path Parameters](https://fastapi.tiangolo.com/tutorial/path-params/)
- [Query Parameters](https://fastapi.tiangolo.com/tutorial/query-params/)

**Request & Response**
- [Request Body](https://fastapi.tiangolo.com/tutorial/body/)
- [Query Parameters and String Validations](https://fastapi.tiangolo.com/tutorial/query-params-str-validations/)
- [Response Model](https://fastapi.tiangolo.com/tutorial/response-model/)

**Database & ORM**
- [SQL Databases](https://fastapi.tiangolo.com/tutorial/sql-databases/)
- [SQLAlchemy](https://fastapi.tiangolo.com/tutorial/sql-databases/)

**Advanced Topics**
- [Dependency Injection](https://fastapi.tiangolo.com/tutorial/dependencies/)
- [Middleware](https://fastapi.tiangolo.com/tutorial/middleware/)
- [CORS](https://fastapi.tiangolo.com/tutorial/cors/)
- [Error Handling](https://fastapi.tiangolo.com/tutorial/handling-errors/)
- [Background Tasks](https://fastapi.tiangolo.com/tutorial/background-tasks/)
- [WebSockets](https://fastapi.tiangolo.com/tutorial/websockets/)

**Security**
- [Security Introduction](https://fastapi.tiangolo.com/tutorial/security/)
- [OAuth2 with Password](https://fastapi.tiangolo.com/tutorial/security/oauth2-jwt/)
- [JWT Tokens](https://fastapi.tiangolo.com/tutorial/security/oauth2-jwt/)

**Testing & Deployment**
- [Testing](https://fastapi.tiangolo.com/tutorial/testing/)
- [Deployment](https://fastapi.tiangolo.com/deployment/)

### 🔗 Related Tools

**Pydantic** (Data Validation)
- https://docs.pydantic.dev/

**SQLAlchemy** (ORM)
- https://docs.sqlalchemy.org/

**Uvicorn** (ASGI Server)
- https://www.uvicorn.org/

---

## Quick Cheat Sheet

```python
# Minimal app
from fastapi import FastAPI

app = FastAPI()

# GET route
@app.get("/users")
def list_users():
    return []

# POST with body
from pydantic import BaseModel

class User(BaseModel):
    name: str
    email: str

@app.post("/users")
def create_user(user: User):
    return user

# Path parameter
@app.get("/users/{user_id}")
def get_user(user_id: int):
    return {"id": user_id}

# Query parameters
@app.get("/search")
def search(q: str, limit: int = 10):
    return {"query": q, "limit": limit}

# Delete with status code
from fastapi import status

@app.delete("/users/{user_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_user(user_id: int):
    pass

# Error handling
from fastapi import HTTPException

@app.get("/items/{item_id}")
def get_item(item_id: int):
    if item_id == 999:
        raise HTTPException(status_code=404, detail="Not found")
    return {"id": item_id}
```

---

## Next Steps

Once you understand these concepts, you're ready for:
- **Lab 01** — Environment setup
- **Lab 02** — Building your first API
- **Lab 03** — Adding a database
- **Lab 04** — Frontend integration

💡 **Pro Tip**: Keep this reference open while working through the labs. Come back here whenever you need to refresh your memory on a decorator or pattern!
