import pytest
from fpdf import FPDF
from app.services.pdf_parser import PdfExtractorService

def generate_sample_invoice_pdf() -> bytes:
    """Gera um PDF sintético em memória contendo cabeçalho e tabela estruturada de fornecedor."""
    pdf = FPDF()
    pdf.add_page()
    pdf.set_font("Helvetica", "B", 14)
    pdf.cell(0, 10, text="Distribuidora Atacadista São Paulo LTDA", new_x="LMARGIN", new_y="NEXT")
    
    pdf.set_font("Helvetica", size=10)
    pdf.cell(0, 8, text="CNPJ: 12.345.678/0001-90 | Pedido de Reposição #2026-99", new_x="LMARGIN", new_y="NEXT")
    pdf.ln(4)

    # Tabela com colunas: Código, Descrição, Qtd, Unidade, Valor Unitário, Subtotal
    table_data = [
        ["Código", "Descrição do Produto", "Qtd", "Unidade", "Vlr Unit", "Subtotal"],
        ["78901", "Arroz Branco Nobre 5kg", "10", "pct", "R$ 29,90", "R$ 299,00"],
        ["78902", "Feijão Carioca Especial 1kg", "20", "un", "R$ 7,50", "R$ 150,00"],
        ["78903", "Óleo de Soja Refinado 900ml", "30", "cx", "R$ 6,20", "R$ 186,00"],
        ["78904", "Leite Integral UHT 1L", "48", "un", "R$ 4,50", "R$ 216,00"],
        ["78905", "Queijo Mussarela Peça", "5.5", "kg", "R$ 38,00", "R$ 209,00"],
    ]

    with pdf.table() as table:
        for row in table_data:
            table_row = table.row()
            for cell in row:
                table_row.cell(cell)

    pdf.ln(5)
    pdf.set_font("Helvetica", "B", 11)
    pdf.cell(0, 8, text="Total Geral do Pedido: R$ 1.060,00", new_x="LMARGIN", new_y="NEXT")

    return bytes(pdf.output())

def test_currency_br_parsing():
    """Valida a conversão correta de moedas nos formatos brasileiros comuns."""
    assert PdfExtractorService.parse_currency_br("R$ 1.250,50") == 1250.50
    assert PdfExtractorService.parse_currency_br("1.250,50") == 1250.50
    assert PdfExtractorService.parse_currency_br("R$ 29,90") == 29.90
    assert PdfExtractorService.parse_currency_br("150,00") == 150.00
    assert PdfExtractorService.parse_currency_br("4.50") == 4.50
    assert PdfExtractorService.parse_currency_br("0,00") == 0.0
    assert PdfExtractorService.parse_currency_br("") == 0.0
    assert PdfExtractorService.parse_currency_br(None) == 0.0

def test_unit_normalization():
    """Valida a padronização de unidades diversas (cx, fardo, kg, un)."""
    assert PdfExtractorService.normalize_unit("UN") == "un"
    assert PdfExtractorService.normalize_unit("unidade") == "un"
    assert PdfExtractorService.normalize_unit("und") == "un"
    assert PdfExtractorService.normalize_unit("CX") == "cx"
    assert PdfExtractorService.normalize_unit("caixas") == "cx"
    assert PdfExtractorService.normalize_unit("KG") == "kg"
    assert PdfExtractorService.normalize_unit("quilos") == "kg"
    assert PdfExtractorService.normalize_unit("pct") == "pct"
    assert PdfExtractorService.normalize_unit("pacotes") == "pct"
    assert PdfExtractorService.normalize_unit("fardo") == "fd"
    assert PdfExtractorService.normalize_unit("desconhecido") == "un"

def test_quantity_parsing():
    """Valida a conversão de quantidades fracionadas e inteiras."""
    assert PdfExtractorService.parse_quantity("10") == 10.0
    assert PdfExtractorService.parse_quantity("5,5") == 5.5
    assert PdfExtractorService.parse_quantity("12.75") == 12.75
    assert PdfExtractorService.parse_quantity(None) == 1.0

def test_pdf_extraction_end_to_end():
    """Valida a extração completa a partir do PDF sintético."""
    pdf_bytes = generate_sample_invoice_pdf()
    assert len(pdf_bytes) > 0

    result = PdfExtractorService.extract_from_bytes(pdf_bytes)

    assert result.total_items_count == 5
    assert len(result.items) == 5

    # Validar detecção de fornecedor
    assert result.detected_supplier is not None
    assert "Distribuidora" in result.detected_supplier

    # Validar primeiro item (Arroz)
    arroz = result.items[0]
    assert "Arroz" in arroz.description
    assert arroz.quantity == 10.0
    assert arroz.unit == "pct"
    assert arroz.unit_price == 29.90
    assert arroz.subtotal == 299.00

    # Validar item com decimal (Queijo)
    queijo = [i for i in result.items if "Queijo" in i.description][0]
    assert queijo.quantity == 5.5
    assert queijo.unit == "kg"
    assert queijo.unit_price == 38.00
    assert queijo.subtotal == 209.00

    # Validar cálculo total geral
    # 299.00 + 150.00 + 186.00 + 216.00 + 209.00 = 1060.00
    assert result.calculated_total_value == 1060.00
