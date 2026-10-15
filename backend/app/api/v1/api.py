from fastapi import APIRouter
from app.api.v1.endpoints import extract, stores, auth

api_router = APIRouter()

api_router.include_router(extract.router, prefix="", tags=["Extração PDF"])
api_router.include_router(stores.router, prefix="/stores", tags=["Lojas e Listas"])
api_router.include_router(auth.router, prefix="/auth", tags=["Autenticação & Membros"])
