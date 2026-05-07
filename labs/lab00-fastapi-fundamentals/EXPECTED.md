# Lab 00 — What to Expect

This is a **reference lab** — there's nothing to build, no code to write. Instead, you should:

---

## 📖 Read Through These Files

### 1. **README.md** (This Directory)
**Contains:**
- What is FastAPI?
- Installation & setup
- Core concepts (routes, parameters, models, etc.)
- All HTTP method decorators (GET, POST, PUT, PATCH, DELETE)
- Request parameters (path, query, body, headers, cookies)
- Request & response models
- Common patterns
- Error handling
- Testing your API
- **Complete documentation links** (scroll to bottom)

**Time to read:** 20-30 minutes

**Key sections to focus on:**
- HTTP Method Decorators
- Request Parameters
- Request & Response Models
- Common Patterns
- Error Handling

---

### 2. **SPEC.md** (This Directory)
**Contains:**
- Checklist of concepts you should understand
- Example patterns you'll use in Labs 01-05
- Code patterns for each lab
- Common pitfalls to avoid
- Self-assessment questions

**Time to read:** 10-15 minutes

**What to do:**
- Go through the checklist
- Make sure you understand each concept
- Can you answer the self-assessment questions?

---

### 3. **examples.py** (This Directory)
**Contains:**
- Complete, working FastAPI code
- Examples of all HTTP methods
- Request/response models
- Error handling
- Database injection
- Status codes

**How to use:**
```bash
cd /path/to/labs/lab00-fastapi-fundamentals

# Run the examples
uv add fastapi uvicorn
uv run uvicorn examples:app --reload

# Visit http://localhost:8000/docs
# Try the endpoints in Swagger UI
# Read the docstrings for each function
```

---

## 🎯 Learning Objectives

After completing Lab 00, you should be able to:

- [ ] Explain the difference between GET, POST, PUT, PATCH, DELETE
- [ ] Write a simple FastAPI route with a path parameter
- [ ] Write a route that accepts query parameters
- [ ] Create a Pydantic model for request validation
- [ ] Understand response models
- [ ] Know when to return different HTTP status codes (200, 201, 204, 400, 404, 422)
- [ ] Raise HTTPException for error conditions
- [ ] Understand dependency injection with `Depends()`
- [ ] Enable CORS for a React frontend
- [ ] Test your API using Swagger UI
- [ ] Know where to find official FastAPI documentation

---

## 🔗 Key Documentation Links to Bookmark

### Official Docs
- **Main**: https://fastapi.tiangolo.com/
- **Tutorial**: https://fastapi.tiangolo.com/tutorial/
- **Advanced**: https://fastapi.tiangolo.com/advanced/

### Quick Reference Topics
- **Path Parameters**: https://fastapi.tiangolo.com/tutorial/path-params/
- **Query Parameters**: https://fastapi.tiangolo.com/tutorial/query-params/
- **Request Body**: https://fastapi.tiangolo.com/tutorial/body/
- **Response Model**: https://fastapi.tiangolo.com/tutorial/response-model/
- **Status Codes**: https://fastapi.tiangolo.com/tutorial/response-status-code/
- **Error Handling**: https://fastapi.tiangolo.com/tutorial/handling-errors/
- **CORS**: https://fastapi.tiangolo.com/tutorial/cors/
- **Dependencies**: https://fastapi.tiangolo.com/tutorial/dependencies/
- **Database**: https://fastapi.tiangolo.com/tutorial/sql-databases/

### Related Tools
- **Pydantic**: https://docs.pydantic.dev/
- **SQLAlchemy**: https://docs.sqlalchemy.org/
- **Uvicorn**: https://www.uvicorn.org/

---

## 📝 Quick Cheat Sheet

### HTTP Methods
```python
@app.get("/items")           # Retrieve data
@app.post("/items")          # Create data
@app.put("/items/{id}")      # Replace data
@app.patch("/items/{id}")    # Partially update data
@app.delete("/items/{id}")   # Delete data
```

### Parameters
```python
# Path parameter (required)
@app.get("/items/{item_id}")
def get_item(item_id: int):
    pass

# Query parameter (optional with default)
@app.get("/items")
def list_items(skip: int = 0, limit: int = 10):
    pass

# Request body (required, JSON)
from pydantic import BaseModel

class Item(BaseModel):
    name: str
    price: float

@app.post("/items")
def create_item(item: Item):
    pass
```

### Status Codes
```python
from fastapi import status

@app.post("/items", status_code=status.HTTP_201_CREATED)
def create_item(item: Item):
    return item

@app.delete("/items/{id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_item(item_id: int):
    pass
```

### Error Handling
```python
from fastapi import HTTPException

@app.get("/items/{item_id}")
def get_item(item_id: int):
    if item_id == 999:
        raise HTTPException(status_code=404, detail="Not found")
    return {"id": item_id}
```

### Database Injection
```python
from fastapi import Depends
from sqlalchemy.orm import Session

@app.get("/items")
def list_items(db: Session = Depends(get_db)):
    return db.query(Item).all()
```

---

## 💡 Pro Tips

1. **Use Swagger UI** (`/docs`) to test your API interactively
2. **Type hints are mandatory** — they enable validation and documentation
3. **Keep response models separate** from request models
4. **Always set correct status codes** — 201 for POST, 204 for DELETE
5. **Enable CORS early** — you'll need it for React frontend
6. **Test with curl or Swagger** before writing frontend code
7. **Read error messages carefully** — Pydantic validation errors are very helpful

---

## ✅ Before You Move to Lab 01

Make sure you can:

- [ ] Run the example code: `uv run uvicorn examples:app --reload`
- [ ] Access Swagger UI at `http://localhost:8000/docs`
- [ ] Test a GET request in Swagger UI
- [ ] Test a POST request with JSON body in Swagger UI
- [ ] Understand what response_model does
- [ ] Explain why you need `from_attributes = True` in Pydantic Config
- [ ] Know where to find official documentation for any decorator

---

## 🚀 Next Steps

1. **Read README.md** (20-30 min)
2. **Read SPEC.md** (10-15 min)
3. **Run examples.py** and test endpoints (10-15 min)
4. **Bookmark documentation links**
5. **Move to Lab 01** when ready!

---

## Questions?

**Reference these as you code Labs 01-05:**

- 🤔 "How do I write a POST endpoint?" → See `examples.py` for `@app.post` examples
- 🤔 "What status code should I return?" → See status codes section above
- 🤔 "How do I validate input?" → See Pydantic models section
- 🤔 "How do I handle errors?" → See error handling section
- 🤔 "How do I connect to database?" → See database injection pattern
- 🤔 "How do I test my API?" → Use Swagger UI at `/docs`

**Come back to this lab whenever you're stuck!** It's your reference guide. 📚
