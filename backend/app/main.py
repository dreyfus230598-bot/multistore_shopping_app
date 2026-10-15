from fastapi import FastAPI
from fastapi.responses import HTMLResponse
from fastapi.middleware.cors import CORSMiddleware
from app.api.v1.api import api_router
from app.web_client import get_mobile_web_html

app = FastAPI(
    title="Multi-Store Grocery & Replenishment API",
    description="Backend API especializada em extração de tabelas de PDF de fornecedores e sincronização de compras multiloja.",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
)

# Habilitar CORS para o app Flutter (Web, iOS, Android)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Conectar rotas versionadas v1
app.include_router(api_router, prefix="/api/v1")

@app.get("/", response_class=HTMLResponse, tags=["Mobile Web PWA"])
@app.get("/app", response_class=HTMLResponse, tags=["Mobile Web PWA"])
async def serve_iphone_app():
    """Interface PWA otimizada para iPhone com suporte a Tela de Início e iOS HIG."""
    return HTMLResponse(content=get_mobile_web_html())

@app.get("/health", tags=["Health"])
async def health_check():
    return {
        "status": "online",
        "service": "multistore-shopping-api",
        "version": "1.0.0",
    }
