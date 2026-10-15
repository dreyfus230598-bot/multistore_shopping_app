import io
import pytest
from fastapi.testclient import TestClient
from app.main import app
from tests.test_pdf_parser import generate_sample_invoice_pdf

client = TestClient(app)

def test_health_check():
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "online"

def test_stores_list_and_toggle():
    # 1. Listar lojas
    res_stores = client.get("/api/v1/stores/")
    assert res_stores.status_code == 200
    stores = res_stores.json()
    assert len(stores) >= 6
    assert stores[0]["code"] == "LJ01"

    # 2. Listar itens da loja 1
    res_items = client.get("/api/v1/stores/store-1/items")
    assert res_items.status_code == 200
    items = res_items.json()
    assert len(items) >= 2

    # 3. Alternar status (tick)
    target_item = items[0]
    initial_status = target_item["is_purchased"]
    res_toggle = client.post(f"/api/v1/stores/items/{target_item['id']}/toggle?buyer_name=TestBuyer")
    assert res_toggle.status_code == 200
    updated_item = res_toggle.json()
    assert updated_item["is_purchased"] == (not initial_status)

def test_pdf_upload_endpoint_success():
    pdf_bytes = generate_sample_invoice_pdf()
    files = {
        "file": ("pedido_fornecedor.pdf", io.BytesIO(pdf_bytes), "application/pdf")
    }
    response = client.post("/api/v1/extract-pdf", files=files)
    assert response.status_code == 200
    data = response.json()
    assert "items" in data
    assert data["total_items_count"] == 5
    assert data["calculated_total_value"] == 1060.00

def test_pdf_upload_invalid_file():
    files = {
        "file": ("imagem.png", io.BytesIO(b"fake png content"), "image/png")
    }
    response = client.post("/api/v1/extract-pdf", files=files)
    assert response.status_code == 400
    assert "PDF" in response.json()["detail"]

def test_apple_account_deletion_compliance():
    # Teste de conformidade com a Apple App Store: Usuário solicitando exclusão de conta
    response = client.post("/api/v1/auth/delete-account", json={"confirm_deletion": True, "reason": "Teste App Store"})
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "success"
    assert "excluídos permanentemente" in data["message"]

def test_apple_account_deletion_without_confirmation():
    response = client.post("/api/v1/auth/delete-account", json={"confirm_deletion": False})
    assert response.status_code == 400
