from fastapi import APIRouter, UploadFile, File, HTTPException, status
from app.schemas.shopping import ExtractedListResponse
from app.services.pdf_parser import PdfExtractorService

router = APIRouter()

@router.post(
    "/extract-pdf",
    response_model=ExtractedListResponse,
    summary="Extrair itens de compras a partir de arquivo PDF",
    description="Processa faturas, pedidos e tabelas de fornecedores em PDF, extraindo descrição, quantidade, unidade, preço unitário e calculando subtotais e valor total.",
)
async def extract_pdf(
    file: UploadFile = File(..., description="Arquivo PDF do pedido ou fatura do fornecedor"),
) -> ExtractedListResponse:
    # 1. Validação do tipo de arquivo
    filename = file.filename or ""
    if not (filename.lower().endswith(".pdf") or (file.content_type and "pdf" in file.content_type.lower())):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Arquivo inválido. O endpoint aceita exclusivamente documentos no formato PDF (.pdf).",
        )

    # 2. Leitura dos bytes do arquivo
    try:
        content = await file.read()
        if len(content) == 0:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="O arquivo enviado está vazio.",
            )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Falha ao ler o conteúdo do arquivo: {str(e)}",
        )

    # 3. Execução do motor de extração
    try:
        extraction_result = PdfExtractorService.extract_from_bytes(content)
        return extraction_result
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail=f"Não foi possível processar o documento PDF informado: {str(e)}",
        )
