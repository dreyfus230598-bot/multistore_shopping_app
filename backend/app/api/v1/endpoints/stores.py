from typing import List
from fastapi import APIRouter, HTTPException, status
from app.schemas.store import StoreSchema, ShoppingItemSchema, StoreCreateSchema
from app.schemas.shopping import MergePdfItemsRequest

router = APIRouter()

# Base em memória para demonstrar e testar sincronização multiloja em tempo real
STORES_DB: List[dict] = [
    {"id": "store-1", "code": "LJ01", "name": "Loja Centro", "address": "Rua XV de Novembro, 100", "color_hex": "#007AFF"},
    {"id": "store-2", "code": "LJ02", "name": "Loja Jardins", "address": "Av. Paulista, 1500", "color_hex": "#34C759"},
    {"id": "store-3", "code": "LJ03", "name": "Loja Express Norte", "address": "Rua Voluntários da Pátria, 420", "color_hex": "#FF9500"},
    {"id": "store-4", "code": "LJ04", "name": "Loja Shopping Sul", "address": "Av. Ibirapuera, 3103", "color_hex": "#AF52DE"},
    {"id": "store-5", "code": "LJ05", "name": "Loja Bairro Alto", "address": "Rua das Laranjeiras, 85", "color_hex": "#FF2D55"},
    {"id": "store-6", "code": "LJ06", "name": "Loja Depósito Central", "address": "Av. das Nações Unidas, 9000", "color_hex": "#5856D6"},
]

ITEMS_DB: List[dict] = [
    # Itens iniciais para LJ01
    {
        "id": "item-1",
        "store_id": "store-1",
        "description": "Leite Integral UHT 1L",
        "quantity": 24.0,
        "unit": "un",
        "unit_price": 4.89,
        "subtotal": 117.36,
        "is_purchased": False,
        "purchased_at": None,
        "purchased_by": None,
        "category": "Laticínios",
    },
    {
        "id": "item-2",
        "store_id": "store-1",
        "description": "Arroz Branco Tipo 1 5kg",
        "quantity": 10.0,
        "unit": "pct",
        "unit_price": 28.50,
        "subtotal": 285.00,
        "is_purchased": False,
        "purchased_at": None,
        "purchased_by": None,
        "category": "Mercearia",
    },
    {
        "id": "item-3",
        "store_id": "store-1",
        "description": "Café Tradicional Torrado 500g",
        "quantity": 15.0,
        "unit": "pct",
        "unit_price": 16.90,
        "subtotal": 253.50,
        "is_purchased": True,
        "purchased_at": "2026-10-15T15:30:00",
        "purchased_by": "Carlos (Comprador)",
        "category": "Mercearia",
    },
    # Itens para LJ02
    {
        "id": "item-4",
        "store_id": "store-2",
        "description": "Óleo de Soja 900ml",
        "quantity": 30.0,
        "unit": "un",
        "unit_price": 6.45,
        "subtotal": 193.50,
        "is_purchased": False,
        "purchased_at": None,
        "purchased_by": None,
        "category": "Mercearia",
    },
]

@router.get("/", response_model=List[StoreSchema], summary="Listar todas as lojas")
async def list_stores() -> List[StoreSchema]:
    res = []
    for s in STORES_DB:
        store_items = [i for i in ITEMS_DB if i["store_id"] == s["id"]]
        pending = sum(1 for i in store_items if not i["is_purchased"])
        purchased = sum(1 for i in store_items if i["is_purchased"])
        total_b = sum(i["subtotal"] for i in store_items)
        res.append(
            StoreSchema(
                id=s["id"],
                code=s["code"],
                name=s["name"],
                address=s.get("address"),
                color_hex=s.get("color_hex", "#007AFF"),
                pending_items_count=pending,
                purchased_items_count=purchased,
                total_budget=round(total_b, 2),
            )
        )
    return res

@router.post("/", response_model=StoreSchema, status_code=status.HTTP_201_CREATED, summary="Criar nova loja dinâmica")
async def create_store(payload: StoreCreateSchema) -> StoreSchema:
    new_id = f"store-{len(STORES_DB) + 1}"
    new_store = {
        "id": new_id,
        "code": payload.code.upper(),
        "name": payload.name,
        "address": payload.address,
        "color_hex": payload.color_hex,
    }
    STORES_DB.append(new_store)
    return StoreSchema(
        id=new_id,
        code=new_store["code"],
        name=new_store["name"],
        address=new_store["address"],
        color_hex=new_store["color_hex"],
        pending_items_count=0,
        purchased_items_count=0,
        total_budget=0.0,
    )

@router.get("/{store_id}/items", response_model=List[ShoppingItemSchema], summary="Listar itens da lista ativa da loja")
async def get_store_items(store_id: str) -> List[ShoppingItemSchema]:
    items = [i for i in ITEMS_DB if i["store_id"] == store_id]
    return [ShoppingItemSchema(**i) for i in items]

@router.post("/items/{item_id}/toggle", response_model=ShoppingItemSchema, summary="Alternar status comprado (Tick em tempo real)")
async def toggle_item_status(item_id: str, buyer_name: str = "Comprador Atual") -> ShoppingItemSchema:
    for item in ITEMS_DB:
        if item["id"] == item_id:
            item["is_purchased"] = not item["is_purchased"]
            if item["is_purchased"]:
                import datetime
                item["purchased_at"] = datetime.datetime.now()
                item["purchased_by"] = buyer_name
            else:
                item["purchased_at"] = None
                item["purchased_by"] = None
            return ShoppingItemSchema(**item)
    raise HTTPException(status_code=404, detail="Item não encontrado")

@router.post("/merge-pdf-items", response_model=List[ShoppingItemSchema], summary="Mesclar itens revisados do PDF na loja de destino")
async def merge_pdf_items(payload: MergePdfItemsRequest) -> List[ShoppingItemSchema]:
    store_exists = any(s["id"] == payload.store_id for s in STORES_DB)
    if not store_exists:
        raise HTTPException(status_code=404, detail="Loja de destino especificada não encontrada")

    added_items = []
    for item in payload.items:
        new_item = {
            "id": f"item-{len(ITEMS_DB) + 1}",
            "store_id": payload.store_id,
            "description": item.description,
            "quantity": item.quantity,
            "unit": item.unit,
            "unit_price": item.unit_price,
            "subtotal": item.subtotal,
            "is_purchased": False,
            "purchased_at": None,
            "purchased_by": None,
            "category": "Extraído via PDF",
        }
        ITEMS_DB.append(new_item)
        added_items.append(ShoppingItemSchema(**new_item))

    return added_items
