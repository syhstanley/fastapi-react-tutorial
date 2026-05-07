"""
Lab 00 — Complete FastAPI Examples
Reference code for common patterns you'll use in Labs 01-05
"""

from fastapi import FastAPI, HTTPException, Depends, status
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from sqlalchemy import Column, Integer, String, Float
from sqlalchemy.orm import Session

# ============================================================================
# BASIC SETUP
# ============================================================================

app = FastAPI()

# Enable CORS for React frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:5173", "http://localhost:3000"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ============================================================================
# PYDANTIC MODELS (Request/Response Validation)
# ============================================================================

class ItemBase(BaseModel):
    """Common fields for Item"""
    name: str
    price: float
    description: str | None = None


class ItemCreate(ItemBase):
    """Model for creating an item (what client sends)"""
    pass


class ItemResponse(ItemBase):
    """Model for returning an item (what server sends)"""
    id: int

    class Config:
        from_attributes = True  # Support SQLAlchemy models


class UserCreate(BaseModel):
    """Model for user creation"""
    name: str
    email: str


class UserResponse(BaseModel):
    """Model for user response"""
    id: int
    name: str
    email: str

    class Config:
        from_attributes = True


# ============================================================================
# SQLALCHEMY MODEL (Optional — for database)
# ============================================================================

class Item:
    """SQLAlchemy ORM model (example)"""
    __tablename__ = "items"

    id = Column(Integer, primary_key=True)
    name = Column(String, nullable=False)
    price = Column(Float, nullable=False)
    description = Column(String, nullable=True)


# ============================================================================
# IN-MEMORY STORAGE (For testing without database)
# ============================================================================

# Simulated database
items_db = []
users_db = []
next_item_id = 1
next_user_id = 1


# ============================================================================
# SIMPLE GET — No Parameters
# ============================================================================

@app.get("/items", response_model=list[ItemResponse])
def list_items():
    """Get all items"""
    return items_db


@app.get("/users", response_model=list[UserResponse])
def list_users():
    """Get all users"""
    return users_db


# ============================================================================
# GET WITH PATH PARAMETER
# ============================================================================

@app.get("/items/{item_id}", response_model=ItemResponse)
def get_item(item_id: int):
    """Get a specific item by ID

    Path parameter: {item_id} is required and must be an integer
    Returns 404 if item not found
    """
    for item in items_db:
        if item["id"] == item_id:
            return item
    raise HTTPException(status_code=404, detail="Item not found")


@app.get("/users/{user_id}", response_model=UserResponse)
def get_user(user_id: int):
    """Get a specific user by ID"""
    for user in users_db:
        if user["id"] == user_id:
            return user
    raise HTTPException(status_code=404, detail="User not found")


# ============================================================================
# GET WITH QUERY PARAMETERS
# ============================================================================

@app.get("/search")
def search(q: str, limit: int = 10, skip: int = 0):
    """Search items

    Query parameters:
    - q: search query (required)
    - limit: max results (optional, default=10)
    - skip: results to skip (optional, default=0)

    Example: GET /search?q=widget&limit=20&skip=0
    """
    matching = [item for item in items_db if q.lower() in item["name"].lower()]
    return {
        "query": q,
        "total": len(matching),
        "limit": limit,
        "skip": skip,
        "results": matching[skip : skip + limit]
    }


@app.get("/items-filtered")
def list_items_filtered(min_price: float = 0, max_price: float = 999999):
    """Filter items by price range

    Query parameters:
    - min_price: minimum price (optional, default=0)
    - max_price: maximum price (optional, default=999999)
    """
    return [
        item for item in items_db
        if min_price <= item["price"] <= max_price
    ]


# ============================================================================
# POST — Create with Request Body
# ============================================================================

@app.post("/items", response_model=ItemResponse, status_code=status.HTTP_201_CREATED)
def create_item(item: ItemCreate):
    """Create a new item

    Request body: JSON with name, price, description (optional)
    Returns: Created item with auto-generated ID
    Status code: 201 (Created)
    """
    global next_item_id
    new_item = {
        "id": next_item_id,
        **item.model_dump()
    }
    items_db.append(new_item)
    next_item_id += 1
    return new_item


@app.post("/users", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
def create_user(user: UserCreate):
    """Create a new user"""
    global next_user_id
    new_user = {
        "id": next_user_id,
        "name": user.name,
        "email": user.email
    }
    users_db.append(new_user)
    next_user_id += 1
    return new_user


# ============================================================================
# PUT — Replace Entire Resource
# ============================================================================

@app.put("/items/{item_id}", response_model=ItemResponse)
def update_item(item_id: int, item: ItemCreate):
    """Replace an entire item

    Path parameter: {item_id} - the item to replace
    Request body: JSON with all item fields
    """
    for i, existing_item in enumerate(items_db):
        if existing_item["id"] == item_id:
            updated = {
                "id": item_id,
                **item.model_dump()
            }
            items_db[i] = updated
            return updated
    raise HTTPException(status_code=404, detail="Item not found")


# ============================================================================
# PATCH — Partial Update
# ============================================================================

@app.patch("/items/{item_id}", response_model=ItemResponse)
def partial_update_item(item_id: int, name: str | None = None, price: float | None = None):
    """Partially update an item

    Only update fields that are provided
    """
    for item in items_db:
        if item["id"] == item_id:
            if name:
                item["name"] = name
            if price:
                item["price"] = price
            return item
    raise HTTPException(status_code=404, detail="Item not found")


# ============================================================================
# DELETE — Remove Resource
# ============================================================================

@app.delete("/items/{item_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_item(item_id: int):
    """Delete an item

    Returns 204 No Content on success
    Returns 404 if item not found
    """
    for i, item in enumerate(items_db):
        if item["id"] == item_id:
            items_db.pop(i)
            return  # 204 returns no content
    raise HTTPException(status_code=404, detail="Item not found")


@app.delete("/users/{user_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_user(user_id: int):
    """Delete a user"""
    for i, user in enumerate(users_db):
        if user["id"] == user_id:
            users_db.pop(i)
            return
    raise HTTPException(status_code=404, detail="User not found")


# ============================================================================
# VALIDATION EXAMPLES
# ============================================================================

@app.post("/validate-item")
def validate_item(item: ItemCreate):
    """Demonstrates automatic validation

    Try these:
    ✅ POST with valid data:
       {"name": "Widget", "price": 9.99}

    ❌ POST with invalid data:
       {"name": "Widget", "price": "not a number"}  → 422 Error
       {"price": 9.99}  → 422 Error (missing 'name')
    """
    return item


# ============================================================================
# ERROR HANDLING EXAMPLES
# ============================================================================

@app.get("/items-error/{item_id}")
def get_item_with_error_handling(item_id: int):
    """Demonstrates error handling patterns"""

    if item_id < 0:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Item ID must be positive"
        )

    if item_id > 1000:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Item not found"
        )

    for item in items_db:
        if item["id"] == item_id:
            return item

    raise HTTPException(
        status_code=status.HTTP_404_NOT_FOUND,
        detail=f"Item {item_id} not found"
    )


# ============================================================================
# DATABASE INJECTION EXAMPLE (with Depends)
# ============================================================================

def get_db():
    """Dependency to get database session

    In real code, this would return SQLAlchemy Session.
    For this example, we just return a marker.
    """
    class FakeDB:
        def query(self, model):
            return []
    return FakeDB()


@app.get("/db-example")
def example_with_db(db: Session = Depends(get_db)):
    """Example of database injection

    Use this pattern in Labs 03-05 to get database access:
    @app.get("/items")
    def list_items(db: Session = Depends(get_db)):
        return db.query(Item).all()
    """
    return {"db_injected": True}


# ============================================================================
# STATUS CODES REFERENCE
# ============================================================================

@app.post("/status-200")
def status_200():
    """Default: 200 OK (success)"""
    return {"message": "Success"}


@app.post("/status-201", status_code=status.HTTP_201_CREATED)
def status_201():
    """201 Created (resource created)"""
    return {"id": 1, "created": True}


@app.delete("/status-204", status_code=status.HTTP_204_NO_CONTENT)
def status_204():
    """204 No Content (success, but no response body)"""
    pass


@app.get("/status-400")
def status_400(validate: bool):
    """400 Bad Request (invalid input)"""
    if not validate:
        raise HTTPException(status_code=400, detail="Invalid request")
    return {"valid": True}


@app.get("/status-404")
def status_404(found: bool):
    """404 Not Found (resource doesn't exist)"""
    if not found:
        raise HTTPException(status_code=404, detail="Resource not found")
    return {"found": True}


@app.post("/status-422")
def status_422_example(data: ItemCreate):
    """422 Unprocessable Entity (validation failed)

    Try: POST with {"name": "Test", "price": "not a number"}
    FastAPI automatically returns 422 for Pydantic validation errors
    """
    return data


# ============================================================================
# HEALTH CHECK
# ============================================================================

@app.get("/health")
def health():
    """Simple health check endpoint"""
    return {"status": "ok"}


# ============================================================================
# ROOT ENDPOINT
# ============================================================================

@app.get("/")
def root():
    """Root endpoint — returns API info"""
    return {
        "name": "FastAPI Example API",
        "description": "Reference implementation from Lab 00",
        "docs": "http://localhost:8000/docs",
        "endpoints": {
            "items": "/items",
            "users": "/users",
            "search": "/search?q=query",
            "health": "/health"
        }
    }


# ============================================================================
# HOW TO RUN THIS FILE
# ============================================================================

"""
To run this example:

    uv run uvicorn examples:app --reload

Then visit:
    - http://localhost:8000/              (API info)
    - http://localhost:8000/docs          (Swagger UI - interactive testing)
    - http://localhost:8000/redoc         (ReDoc - documentation)

Test endpoints:

# Create an item
curl -X POST http://localhost:8000/items \
  -H "Content-Type: application/json" \
  -d '{"name": "Widget", "price": 9.99}'

# List items
curl http://localhost:8000/items

# Get specific item
curl http://localhost:8000/items/1

# Search
curl "http://localhost:8000/search?q=widget&limit=5"

# Delete
curl -X DELETE http://localhost:8000/items/1

# Or use Swagger UI at http://localhost:8000/docs for interactive testing!
"""

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
