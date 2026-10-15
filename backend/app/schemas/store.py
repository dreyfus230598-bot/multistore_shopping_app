from typing import List, Optional
from datetime import datetime
from pydantic import BaseModel, Field

class ShoppingItemSchema(BaseModel):
    id: str
    store_id: str
    description: str
    quantity: float
    unit: str = "un"
    unit_price: float = 0.0
    subtotal: float = 0.0
    is_purchased: bool = False
    purchased_at: Optional[datetime] = None
    purchased_by: Optional[str] = None
    category: Optional[str] = "Geral"

class StoreSchema(BaseModel):
    id: str
    code: str  # ex: LJ01, LJ02, etc.
    name: str
    address: Optional[str] = None
    color_hex: str = "#007AFF"
    pending_items_count: int = 0
    purchased_items_count: int = 0
    total_budget: float = 0.0

class StoreCreateSchema(BaseModel):
    code: str
    name: str
    address: Optional[str] = None
    color_hex: str = "#007AFF"
