import io
import re
from typing import List, Optional, Tuple
import pdfplumber
from app.schemas.shopping import ItemExtract, ExtractedListResponse

# Mapeamento de unidades de medida brasileiras para formato normalizado
UNIT_NORMALIZATION = {
    "un": "un",
    "und": "un",
    "unid": "un",
    "unidade": "un",
    "unidades": "un",
    "cx": "cx",
    "cxs": "cx",
    "caixa": "cx",
    "caixas": "cx",
    "kg": "kg",
    "kgs": "kg",
    "kilo": "kg",
    "quilo": "kg",
    "quilos": "kg",
    "g": "g",
    "gr": "g",
    "grama": "g",
    "gramas": "g",
    "l": "l",
    "lt": "l",
    "lts": "l",
    "litro": "l",
    "litros": "l",
    "ml": "ml",
    "mls": "ml",
    "pct": "pct",
    "pcte": "pct",
    "pacote": "pct",
    "pacotes": "pct",
    "fd": "fd",
    "fardo": "fd",
    "fardos": "fd",
    "dz": "dz",
    "duzia": "dz",
    "duzias": "dz",
    "sc": "sc",
    "saco": "sc",
    "sacos": "sc",
    "bdj": "bdj",
    "bandeja": "bdj",
    "bandejas": "bdj",
}

class PdfExtractorService:
    """Motor especializado em extração e normalização de itens de compras de PDFs de fornecedores."""

    @staticmethod
    def parse_currency_br(value_str: Optional[str]) -> float:
        """Converte strings financeiras em formato brasileiro (ex: R$ 1.250,50 ou 14,99) para float."""
        if not value_str:
            return 0.0
        
        # Limpar símbolos de moeda e espaços
        cleaned = re.sub(r"[^\d,\.]", "", str(value_str)).strip()
        if not cleaned:
            return 0.0

        # Caso padrão brasileiro: '1.250,50' ou '12,50' (vírgula é decimal)
        if "," in cleaned and "." in cleaned:
            # ex: 1.250,50 -> remove ponto dos milhares e troca vírgula por ponto decimal
            cleaned = cleaned.replace(".", "").replace(",", ".")
        elif "," in cleaned:
            # ex: 12,50 -> 12.50
            cleaned = cleaned.replace(",", ".")
        elif "." in cleaned:
            # ex: 12.50 ou 1.250
            parts = cleaned.split(".")
            if len(parts) == 2 and len(parts[1]) == 2:
                # provável decimal padrão US
                pass
            elif len(parts) == 2 and len(parts[1]) == 3:
                # provável milhar sem centavos, ex: 1.000 -> 1000.0
                cleaned = cleaned.replace(".", "")
            elif len(parts) > 2:
                # múltiplos pontos de milhar
                cleaned = cleaned.replace(".", "")

        try:
            val = float(cleaned)
            return round(val, 2)
        except ValueError:
            return 0.0

    @staticmethod
    def normalize_unit(raw_unit: Optional[str]) -> str:
        """Identifica e normaliza a unidade de medida para o padrão brasileiro."""
        if not raw_unit:
            return "un"
        clean_unit = raw_unit.strip().lower()
        clean_unit = re.sub(r"[^\w]", "", clean_unit)
        return UNIT_NORMALIZATION.get(clean_unit, "un")

    @staticmethod
    def parse_quantity(raw_qty: Optional[str]) -> float:
        """Converte valor de quantidade com suporte a decimais (ex: 2.5 kg ou 10 un)."""
        if not raw_qty:
            return 1.0
        cleaned = str(raw_qty).strip()
        cleaned = re.sub(r"[^\d,\.]", "", cleaned)
        if "," in cleaned:
            cleaned = cleaned.replace(".", "").replace(",", ".")
        try:
            val = float(cleaned)
            return round(val, 3) if val > 0 else 1.0
        except ValueError:
            return 1.0

    @classmethod
    def extract_from_bytes(cls, pdf_bytes: bytes) -> ExtractedListResponse:
        """Processa o PDF a partir de bytes em memória e retorna a lista calculada."""
        items: List[ItemExtract] = []
        detected_supplier: Optional[str] = None
        seen_descriptions = set()

        with pdfplumber.open(io.BytesIO(pdf_bytes)) as pdf:
            # 1. Tentar detectar fornecedor nas primeiras páginas
            if pdf.pages:
                first_page_text = pdf.pages[0].extract_text() or ""
                detected_supplier = cls._detect_supplier(first_page_text)

            # 2. Processar página por página
            for page in pdf.pages:
                page_tables = page.extract_tables()
                page_processed_with_tables = False

                for table in page_tables:
                    extracted_from_table = cls._process_table(table)
                    if extracted_from_table:
                        for item in extracted_from_table:
                            # Evitar duplicações idênticas consecutivas mantendo itens legítimos
                            key = (item.description.lower().strip(), item.quantity, item.unit_price)
                            if key not in seen_descriptions:
                                seen_descriptions.add(key)
                                items.append(item)
                        page_processed_with_tables = True

                # 3. Fallback: Se nenhuma tabela for encontrada ou não renderizar itens, usar parser textual por linha
                if not page_processed_with_tables:
                    page_text = page.extract_text() or ""
                    text_items = cls._process_text_lines(page_text)
                    for item in text_items:
                        key = (item.description.lower().strip(), item.quantity, item.unit_price)
                        if key not in seen_descriptions:
                            seen_descriptions.add(key)
                            items.append(item)

        total_items_count = len(items)
        calculated_total_value = round(sum(item.subtotal for item in items), 2)

        notes = f"Sucesso na extração de {total_items_count} itens." if total_items_count > 0 else "Nenhum item tabular identificado automaticamente. Verifique o modelo do documento."

        return ExtractedListResponse(
            items=items,
            total_items_count=total_items_count,
            calculated_total_value=calculated_total_value,
            detected_supplier=detected_supplier,
            notes=notes,
        )

    @classmethod
    def _detect_supplier(cls, text: str) -> Optional[str]:
        """Heurística para encontrar razão social ou nome de fornecedor no topo do documento."""
        lines = [line.strip() for line in text.split("\n") if line.strip()]
        for line in lines[:10]:
            # Padrões comuns: 'Fornecedor: Distribuidora XYZ', 'Empresa: Atacadista ABC', 'LTDA', 'DISTRIBUIDORA'
            match = re.search(r"(?:fornecedor|distribuidor|razao social|empresa)[\s:]+([A-Za-z0-9\s\.\-&]{3,40})", line, re.IGNORECASE)
            if match:
                return match.group(1).strip()
            if any(term in line.upper() for term in ["ATACADISTA", "DISTRIBUIDORA", "ALIMENTOS LTDA", "COMERCIO LTDA", "S/A"]):
                return line[:40].strip()
        return None

    @classmethod
    def _process_table(cls, table: List[List[Optional[str]]]) -> List[ItemExtract]:
        """Identifica cabeçalhos e extrai itens estruturados de matriz de tabela."""
        if not table or len(table) < 2:
            return []

        # Localizar linha de cabeçalho
        header_row_index = -1
        col_desc = -1
        col_qty = -1
        col_unit = -1
        col_price = -1
        col_subtotal = -1

        for idx, row in enumerate(table[:5]):
            row_str = " ".join([str(c).lower() if c else "" for c in row])
            if any(term in row_str for term in ["descri", "produto", "item", "mercadoria", "material"]):
                header_row_index = idx
                # Mapear índices de colunas
                for c_idx, cell in enumerate(row):
                    if not cell:
                        continue
                    c_clean = str(cell).lower().strip()
                    # 1. Checar Subtotal/Total
                    if any(t in c_clean for t in ["subtotal", "vlr total", "valor total", "vl total"]):
                        col_subtotal = c_idx
                    # 2. Checar Preço Unitário (antes de unidade para não colidir com 'unit')
                    elif any(t in c_clean for t in ["unit", "vlr unit", "unitario", "unitário", "preco", "preço"]):
                        col_price = c_idx
                    # 3. Checar Quantidade
                    elif any(t in c_clean for t in ["qtd", "quant", "quantidade"]):
                        col_qty = c_idx
                    # 4. Checar Unidade de Medida (palavra isolada ou termos específicos)
                    elif c_clean in ["un", "und", "unid", "unidade", "medida", "um", "u.m."] or any(w in c_clean.split() for w in ["un", "unid", "unidade", "medida"]):
                        col_unit = c_idx
                    # 5. Checar Descrição/Produto
                    elif any(t in c_clean for t in ["descri", "produto", "item", "mercadoria", "nome", "especificação"]):
                        col_desc = c_idx
                break

        # Fallback de índices se não encontrou cabeçalho explícito mas tem 4 ou mais colunas
        if header_row_index == -1:
            # Assume formato comum: [Código/Item, Descrição, Qtd, Unidade, Valor Unitário, Subtotal]
            return []

        items: List[ItemExtract] = []
        for row in table[header_row_index + 1 :]:
            if not row or all(c is None or str(c).strip() == "" for c in row):
                continue

            desc_raw = row[col_desc] if col_desc != -1 and col_desc < len(row) else None
            if not desc_raw:
                continue

            desc_clean = str(desc_raw).strip().replace("\n", " ")
            # Ignorar linhas de rodapé ou resumo
            if any(term in desc_clean.lower() for term in ["total geral", "subtotal", "resumo", "pagina", "impostos"]):
                continue

            # Extração de quantidade
            qty_raw = row[col_qty] if col_qty != -1 and col_qty < len(row) else "1"
            quantity = cls.parse_quantity(qty_raw)

            # Extração de unidade
            unit_raw = row[col_unit] if col_unit != -1 and col_unit < len(row) else None
            # Se a unidade estiver colada na descrição ou na quantidade
            unit = cls.normalize_unit(unit_raw)

            # Extração de valor unitário
            price_raw = row[col_price] if col_price != -1 and col_price < len(row) else None
            unit_price = cls.parse_currency_br(price_raw)

            # Extração de subtotal
            subtotal_raw = row[col_subtotal] if col_subtotal != -1 and col_subtotal < len(row) else None
            subtotal_extracted = cls.parse_currency_br(subtotal_raw)

            # Cálculo de consistência: se tiver preço e quantidade, calcula o subtotal
            calculated_subtotal = round(quantity * unit_price, 2)
            final_subtotal = subtotal_extracted if subtotal_extracted > 0 and abs(subtotal_extracted - calculated_subtotal) > 0.05 else (calculated_subtotal if calculated_subtotal > 0 else subtotal_extracted)

            # Se o preço unitário veio zerado mas temos o subtotal e quantidade
            if unit_price == 0.0 and final_subtotal > 0 and quantity > 0:
                unit_price = round(final_subtotal / quantity, 2)

            if len(desc_clean) > 2:
                items.append(
                    ItemExtract(
                        description=desc_clean,
                        quantity=quantity,
                        unit=unit,
                        unit_price=unit_price,
                        subtotal=final_subtotal,
                    )
                )

        return items

    @classmethod
    def _process_text_lines(cls, text: str) -> List[ItemExtract]:
        """Parser heurístico linha por linha para documentos não tabulados ou textos contínuos."""
        items: List[ItemExtract] = []
        lines = text.split("\n")

        # Exemplo regex:
        # ARROZ 5KG - 10 CX x R$ 25,50 = 255,00
        # ou: 01 CAFE PILAO 500G 20 UN 14,90 298,00
        pattern_full = re.compile(
            r"^(?:\d+[\s\.\-]+)?(?P<desc>[A-Za-z0-9\s\.\-\/\(\)%]{3,50}?)\s+"
            r"(?P<qty>\d+(?:[\.,]\d+)?)\s*"
            r"(?P<unit>[A-Za-z]{1,4})\s+"
            r"(?:x\s+|de\s+)?(?:R\$\s*)?(?P<price>\d+(?:[\.,]\d{2}))"
            r"(?:\s*(?:=\s*)?(?:R\$\s*)?(?P<subtotal>\d+(?:[\.,]\d{2})))?",
            re.IGNORECASE,
        )

        for line in lines:
            line_clean = line.strip()
            if not line_clean or any(term in line_clean.lower() for term in ["cnpj", "data", "hora", "total geral", "página", "cupom"]):
                continue

            match = pattern_full.search(line_clean)
            if match:
                desc = match.group("desc").strip()
                qty = cls.parse_quantity(match.group("qty"))
                unit = cls.normalize_unit(match.group("unit"))
                unit_price = cls.parse_currency_br(match.group("price"))
                subtotal_str = match.group("subtotal")
                subtotal = cls.parse_currency_br(subtotal_str) if subtotal_str else round(qty * unit_price, 2)

                if subtotal == 0.0 and unit_price > 0:
                    subtotal = round(qty * unit_price, 2)

                if len(desc) >= 3:
                    items.append(
                        ItemExtract(
                            description=desc,
                            quantity=qty,
                            unit=unit,
                            unit_price=unit_price,
                            subtotal=subtotal,
                        )
                    )

        return items
