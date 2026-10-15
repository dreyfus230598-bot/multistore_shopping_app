from typing import List, Optional
from pydantic import BaseModel, Field

class ItemExtract(BaseModel):
    description: str = Field(..., description="Descrição ou nome do produto")
    quantity: float = Field(..., ge=0, description="Quantidade comprada ou a comprar")
    unit: str = Field("un", description="Unidade de medida normalizada (un, cx, kg, l, pct, fd, etc)")
    unit_price: float = Field(0.0, ge=0, description="Valor unitário do item em Reais (R$)")
    subtotal: float = Field(0.0, ge=0, description="Subtotal calculado (quantidade * valor_unitario)")

class ExtractedListResponse(BaseModel):
    items: List[ItemExtract] = Field(default_factory=list, description="Lista de itens extraídos com sucesso do PDF")
    total_items_count: int = Field(..., description="Quantidade total de itens diferentes identificados")
    calculated_total_value: float = Field(..., description="Soma consolidada de todos os subtotais dos itens (R$)")
    detected_supplier: Optional[str] = Field(None, description="Nome do fornecedor detectado no cabeçalho do documento")
    notes: Optional[str] = Field(None, description="Observações ou avisos da extração")

class MergePdfItemsRequest(BaseModel):
    store_id: str = Field(..., description="ID da loja onde os itens serão mesclados")
    items: List[ItemExtract] = Field(..., description="Lista de itens revisados para inclusão")
