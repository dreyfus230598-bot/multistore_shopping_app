import json

def get_mobile_web_html(api_base_url: str = "") -> str:
    """
    Retorna uma aplicação Web / PWA móvel otimizada especificamente para o iPhone (Safari e Tela de Início),
    seguindo rigorosamente as Apple Human Interface Guidelines (Dynamic Island, Safe Area, Haptic Touch e SF Pro).
    """
    return f"""<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover">
  <title>MultiStore Compras & Reposição</title>
  
  <!-- Configurações Apple iOS PWA / Safari -->
  <meta name="apple-mobile-web-app-capable" content="yes">
  <meta name="apple-mobile-web-app-status-bar-style" content="default">
  <meta name="apple-mobile-web-app-title" content="MultiStore">
  <meta name="theme-color" content="#F2F2F7">
  
  <style>
    :root {{
      --primary-blue: #007AFF;
      --system-green: #34C759;
      --system-red: #FF3B30;
      --system-orange: #FF9500;
      --bg-color: #F2F2F7;
      --card-bg: #FFFFFF;
      --text-primary: #000000;
      --text-secondary: #8E8E93;
      --border-color: #E5E5EA;
      --safe-top: max(env(safe-area-inset-top), 20px);
      --safe-bottom: max(env(safe-area-inset-bottom), 16px);
    }}

    * {{
      box-sizing: border-box;
      -webkit-tap-highlight-color: transparent;
      margin: 0;
      padding: 0;
      font-family: -apple-system, BlinkMacSystemFont, "SF Pro Display", "SF Pro Text", "Helvetica Neue", sans-serif;
    }}

    body {{
      background-color: var(--bg-color);
      color: var(--text-primary);
      padding-top: var(--safe-top);
      padding-bottom: calc(var(--safe-bottom) + 65px);
      min-height: 100vh;
      overflow-x: hidden;
      user-select: none;
      -webkit-user-select: none;
    }}

    /* Cabeçalho Nativo iOS */
    header {{
      background: rgba(255, 255, 255, 0.85);
      backdrop-filter: blur(20px);
      -webkit-backdrop-filter: blur(20px);
      border-bottom: 0.5px solid var(--border-color);
      position: sticky;
      top: 0;
      z-index: 50;
      padding: 12px 16px;
      display: flex;
      justify-content: space-between;
      align-items: center;
    }}

    .header-titles h1 {{
      font-size: 19px;
      font-weight: 700;
      letter-spacing: -0.4px;
    }}

    .header-titles p {{
      font-size: 12px;
      color: var(--text-secondary);
    }}

    .header-actions {{
      display: flex;
      gap: 12px;
    }}

    .icon-btn {{
      background: #E5E5EA;
      border: none;
      width: 36px;
      height: 36px;
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 18px;
      cursor: pointer;
      color: var(--primary-blue);
      transition: transform 0.1s;
    }}

    .icon-btn:active {{
      transform: scale(0.92);
    }}

    /* Barra de Abas das Lojas (LJ01 a LJ06) */
    .store-tabs-wrapper {{
      background: var(--card-bg);
      padding: 10px 16px;
      border-bottom: 0.5px solid var(--border-color);
      display: flex;
      gap: 8px;
      overflow-x: auto;
      scrollbar-width: none;
      -webkit-overflow-scrolling: touch;
    }}
    .store-tabs-wrapper::-webkit-scrollbar {{
      display: none;
    }}

    .store-pill {{
      display: flex;
      align-items: center;
      gap: 6px;
      padding: 7px 14px;
      border-radius: 20px;
      background: #F2F2F7;
      border: 1.5px solid transparent;
      font-size: 13px;
      white-space: nowrap;
      cursor: pointer;
      transition: all 0.2s ease;
    }}

    .store-pill.active {{
      background: rgba(0, 122, 255, 0.12);
      border-color: var(--primary-blue);
      color: var(--primary-blue);
      font-weight: 700;
    }}

    .store-pill .dot {{
      width: 8px;
      height: 8px;
      border-radius: 50%;
    }}

    .store-pill .badge {{
      background: #8E8E93;
      color: white;
      font-size: 10px;
      font-weight: 700;
      padding: 2px 6px;
      border-radius: 10px;
    }}

    .store-pill.active .badge {{
      background: var(--primary-blue);
    }}

    /* Card de Progresso */
    .progress-card {{
      background: var(--card-bg);
      margin: 14px 16px;
      padding: 14px 16px;
      border-radius: 16px;
      border: 0.5px solid var(--border-color);
      box-shadow: 0 2px 8px rgba(0, 0, 0, 0.03);
    }}

    .progress-header {{
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 10px;
    }}

    .progress-title {{
      font-size: 13px;
      font-weight: 600;
      color: #3C3C43;
    }}

    .progress-badge {{
      font-size: 12px;
      font-weight: 700;
      padding: 3px 8px;
      border-radius: 12px;
      background: rgba(0, 122, 255, 0.12);
      color: var(--primary-blue);
    }}

    .progress-badge.done {{
      background: rgba(52, 199, 89, 0.15);
      color: var(--system-green);
    }}

    .progress-track {{
      background: #E5E5EA;
      height: 8px;
      border-radius: 4px;
      overflow: hidden;
    }}

    .progress-fill {{
      background: var(--primary-blue);
      height: 100%;
      width: 0%;
      border-radius: 4px;
      transition: width 0.3s cubic-bezier(0.2, 0.8, 0.2, 1);
    }}

    .progress-fill.done {{
      background: var(--system-green);
    }}

    .progress-footer {{
      display: flex;
      justify-content: space-between;
      margin-top: 8px;
      font-size: 12px;
    }}

    .progress-footer .count {{
      color: var(--text-secondary);
      font-weight: 500;
    }}

    .progress-footer .budget {{
      font-weight: 700;
      color: var(--text-primary);
    }}

    /* Listas de Compras */
    .section-title {{
      font-size: 11.5px;
      font-weight: 800;
      color: var(--text-secondary);
      letter-spacing: 0.6px;
      padding: 8px 20px 4px 20px;
      text-transform: uppercase;
    }}

    .items-list {{
      padding: 0 16px;
      display: flex;
      flex-direction: column;
      gap: 8px;
    }}

    .item-tile {{
      background: var(--card-bg);
      border-radius: 14px;
      border: 0.5px solid var(--border-color);
      padding: 12px 14px;
      display: flex;
      align-items: center;
      gap: 12px;
      transition: all 0.2s ease;
    }}

    .item-tile.purchased {{
      background: #F8F8FA;
      opacity: 0.75;
    }}

    /* Circular Checkbox Apple HIG Touch-friendly */
    .circular-check {{
      width: 32px;
      height: 32px;
      min-width: 32px;
      border-radius: 50%;
      border: 2px solid #C7C7CC;
      display: flex;
      align-items: center;
      justify-content: center;
      cursor: pointer;
      transition: all 0.2s cubic-bezier(0.34, 1.56, 0.64, 1);
    }}

    .circular-check:active {{
      transform: scale(0.85);
    }}

    .circular-check.checked {{
      background: var(--system-green);
      border-color: var(--system-green);
      color: white;
    }}

    .item-info {{
      flex: 1;
      min-width: 0;
    }}

    .item-title {{
      font-size: 15px;
      font-weight: 600;
      color: var(--text-primary);
      margin-bottom: 3px;
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
    }}

    .item-tile.purchased .item-title {{
      text-decoration: line-through;
      color: var(--text-secondary);
    }}

    .item-sub {{
      font-size: 12px;
      color: var(--text-secondary);
      display: flex;
      align-items: center;
      gap: 6px;
    }}

    .item-tile.purchased .item-sub {{
      text-decoration: line-through;
    }}

    .item-tag {{
      background: #E5E5EA;
      color: #1C1C1E;
      font-size: 11px;
      font-weight: 700;
      padding: 2px 6px;
      border-radius: 6px;
    }}

    .item-subtotal {{
      font-size: 14px;
      font-weight: 700;
      color: var(--primary-blue);
      text-align: right;
    }}

    .item-tile.purchased .item-subtotal {{
      color: var(--text-secondary);
      text-decoration: line-through;
    }}

    /* Seção Inferior Já Comprados */
    .purchased-header {{
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 14px 20px 6px 20px;
      cursor: pointer;
    }}

    .purchased-header-left {{
      display: flex;
      align-items: center;
      gap: 6px;
      font-size: 12px;
      font-weight: 800;
      color: var(--system-green);
    }}

    /* Barra de Navegação Inferior Nativa iOS */
    .bottom-nav {{
      position: fixed;
      bottom: 0;
      left: 0;
      right: 0;
      background: rgba(255, 255, 255, 0.9);
      backdrop-filter: blur(25px);
      -webkit-backdrop-filter: blur(25px);
      border-top: 0.5px solid var(--border-color);
      padding: 8px 16px calc(var(--safe-bottom) + 4px) 16px;
      display: flex;
      justify-content: space-around;
      z-index: 90;
    }}

    .nav-item {{
      display: flex;
      flex-direction: column;
      align-items: center;
      font-size: 10px;
      font-weight: 600;
      color: var(--text-secondary);
      background: none;
      border: none;
      cursor: pointer;
      gap: 3px;
    }}

    .nav-item.active {{
      color: var(--primary-blue);
    }}

    .nav-item svg {{
      width: 24px;
      height: 24px;
      fill: currentColor;
    }}

    /* Modais Estilo iOS Bottom Sheet */
    .sheet-overlay {{
      position: fixed;
      inset: 0;
      background: rgba(0, 0, 0, 0.4);
      z-index: 100;
      display: none;
      opacity: 0;
      transition: opacity 0.3s;
    }}

    .sheet-overlay.active {{
      display: block;
      opacity: 1;
    }}

    .bottom-sheet {{
      position: fixed;
      bottom: 0;
      left: 0;
      right: 0;
      background: var(--bg-color);
      border-radius: 24px 24px 0 0;
      z-index: 101;
      max-height: 90vh;
      display: flex;
      flex-direction: column;
      transform: translateY(100%);
      transition: transform 0.35s cubic-bezier(0.16, 1, 0.3, 1);
      padding-bottom: var(--safe-bottom);
    }}

    .bottom-sheet.active {{
      transform: translateY(0);
    }}

    .sheet-handle {{
      width: 40px;
      height: 4.5px;
      background: #C7C7CC;
      border-radius: 3px;
      margin: 10px auto 6px auto;
    }}

    .sheet-header {{
      padding: 12px 20px;
      display: flex;
      justify-content: space-between;
      align-items: center;
      border-bottom: 0.5px solid var(--border-color);
      background: var(--card-bg);
      border-radius: 24px 24px 0 0;
    }}

    .sheet-header h3 {{
      font-size: 17px;
      font-weight: 700;
    }}

    .sheet-close {{
      background: #E5E5EA;
      border: none;
      border-radius: 50%;
      width: 30px;
      height: 30px;
      font-weight: bold;
      color: #3C3C43;
      cursor: pointer;
    }}

    .sheet-content {{
      padding: 16px 20px;
      overflow-y: auto;
      flex: 1;
    }}

    .sheet-footer {{
      padding: 14px 20px;
      background: var(--card-bg);
      border-top: 0.5px solid var(--border-color);
    }}

    .btn-primary {{
      background: var(--primary-blue);
      color: white;
      border: none;
      width: 100%;
      padding: 14px;
      font-size: 16px;
      font-weight: 700;
      border-radius: 14px;
      cursor: pointer;
    }}
    .btn-primary:active {{
      opacity: 0.85;
    }}

    .btn-danger {{
      background: rgba(255, 59, 48, 0.12);
      color: var(--system-red);
      border: 1px solid var(--system-red);
      width: 100%;
      padding: 14px;
      font-size: 15px;
      font-weight: 700;
      border-radius: 14px;
      cursor: pointer;
      margin-top: 12px;
    }}

    /* Upload PDF Zone */
    .upload-zone {{
      border: 2px dashed var(--primary-blue);
      border-radius: 16px;
      background: rgba(0, 122, 255, 0.04);
      padding: 24px 16px;
      text-align: center;
      cursor: pointer;
      margin-bottom: 16px;
    }}

    .upload-zone:active {{
      background: rgba(0, 122, 255, 0.08);
    }}

    .upload-zone p {{
      font-size: 13px;
      color: var(--text-secondary);
      margin-top: 6px;
    }}

    /* Ajuste Stepper Modal */
    .stepper {{
      display: inline-flex;
      background: #E5E5EA;
      border-radius: 8px;
      align-items: center;
    }}
    .stepper button {{
      background: none;
      border: none;
      padding: 6px 10px;
      font-size: 16px;
      font-weight: bold;
      cursor: pointer;
    }}
    .stepper span {{
      font-size: 13px;
      font-weight: bold;
      min-width: 24px;
      text-align: center;
    }}

    /* Botão Flutuante Rápido */
    .fab-add {{
      position: fixed;
      right: 20px;
      bottom: calc(var(--safe-bottom) + 75px);
      background: var(--primary-blue);
      color: white;
      padding: 12px 20px;
      border-radius: 30px;
      box-shadow: 0 4px 14px rgba(0, 122, 255, 0.4);
      display: flex;
      align-items: center;
      gap: 8px;
      font-weight: 700;
      font-size: 14px;
      border: none;
      cursor: pointer;
      z-index: 80;
    }}
    .fab-add:active {{
      transform: scale(0.95);
    }}

    /* Toast */
    .toast {{
      position: fixed;
      top: calc(var(--safe-top) + 60px);
      left: 50%;
      transform: translateX(-50%) translateY(-20px);
      background: rgba(0, 0, 0, 0.85);
      backdrop-filter: blur(10px);
      color: white;
      padding: 10px 18px;
      border-radius: 20px;
      font-size: 13px;
      font-weight: 600;
      opacity: 0;
      pointer-events: none;
      transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1);
      z-index: 200;
    }}
    .toast.show {{
      opacity: 1;
      transform: translateX(-50%) translateY(0);
    }}
  </style>
</head>
<body>

  <!-- Toast Notificação -->
  <div id="toast" class="toast">Ação concluída com sucesso!</div>

  <!-- Header Superior -->
  <header>
    <div class="header-titles">
      <h1 id="headerStoreTitle">LJ01 • Loja Centro</h1>
      <p>Modo Reposição & Compras Multi-Lojas</p>
    </div>
    <div class="header-actions">
      <button class="icon-btn" onclick="openPdfModal()" title="Importar PDF">📄</button>
      <button class="icon-btn" onclick="openShareModal()" title="Delegar Comprador">👥</button>
    </div>
  </header>

  <!-- Abas Horizontais das Lojas (LJ01 a LJ06) -->
  <div class="store-tabs-wrapper" id="storeTabs">
    <!-- Renderizado dinamicamente via JS -->
  </div>

  <!-- Barra de Progresso Visual de Reposição -->
  <div class="progress-card">
    <div class="progress-header">
      <span class="progress-title">Progresso de Compras</span>
      <span class="progress-badge" id="progressBadge">0% Concluído</span>
    </div>
    <div class="progress-track">
      <div class="progress-fill" id="progressFill"></div>
    </div>
    <div class="progress-footer">
      <span class="count" id="progressCount">0 de 0 itens</span>
      <span class="budget" id="progressBudget">Total: R$ 0,00</span>
    </div>
  </div>

  <!-- Seção A Comprar -->
  <div class="section-title" id="pendingTitle">A COMPRAR</div>
  <div class="items-list" id="pendingList">
    <!-- Renderizado dinamicamente -->
  </div>

  <!-- Seção Já Comprados -->
  <div class="purchased-header" onclick="togglePurchasedSection()">
    <div class="purchased-header-left">
      <span>✓</span>
      <span id="purchasedTitle">JÁ COMPRADOS (0)</span>
    </div>
    <span id="purchasedArrow">▲</span>
  </div>
  <div class="items-list" id="purchasedList">
    <!-- Itens comprados com estilo tachado -->
  </div>

  <!-- Botão Flutuante Adicionar Item Rápido -->
  <button class="fab-add" onclick="openAddItemModal()">
    <span>+</span>
    <span>Novo Item</span>
  </button>

  <!-- Barra de Navegação Inferior (Estilo Apple HIG) -->
  <nav class="bottom-nav">
    <button class="nav-item active" onclick="switchNav('compras')">
      <svg viewBox="0 0 24 24"><path d="M7 18c-1.1 0-1.99.9-1.99 2S5.9 22 7 22s2-.9 2-2-.9-2-2-2zM1 2v2h2l3.6 7.59-1.35 2.45c-.16.28-.25.61-.25.96 0 1.1.9 2 2 2h12v-2H7.42c-.14 0-.25-.11-.25-.25l.03-.12.9-1.63h7.45c.75 0 1.41-.41 1.75-1.03l3.58-6.49c.08-.14.12-.31.12-.48 0-.55-.45-1-1-1H5.21l-.94-2H1zm16 16c-1.1 0-1.99.9-1.99 2s.89 2 1.99 2 2-.9 2-2-.9-2-2-2z"/></svg>
      Compras
    </button>
    <button class="nav-item" onclick="openPdfModal()">
      <svg viewBox="0 0 24 24"><path d="M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-5 14H7v-2h7v2zm3-4H7v-2h10v2zm0-4H7V7h10v2z"/></svg>
      Ler PDF
    </button>
    <button class="nav-item" onclick="openShareModal()">
      <svg viewBox="0 0 24 24"><path d="M16 11c1.66 0 2.99-1.34 2.99-3S17.66 5 16 5c-1.66 0-3 1.34-3 3s1.34 3 3 3zm-8 0c1.66 0 2.99-1.34 2.99-3S9.66 5 8 5C6.34 5 5 6.34 5 8s1.34 3 3 3zm0 2c-2.33 0-7 1.17-7 3.5V19h14v-2.5c0-2.33-4.67-3.5-7-3.5zm8 0c-.29 0-.62.02-.97.05 1.16.84 1.97 1.97 1.97 3.45V19h6v-2.5c0-2.33-4.67-3.5-7-3.5z"/></svg>
      Equipe
    </button>
    <button class="nav-item" onclick="openSettingsModal()">
      <svg viewBox="0 0 24 24"><path d="M19.14 12.94c.04-.3.06-.61.06-.94 0-.32-.02-.64-.07-.94l2.03-1.58c.18-.14.23-.41.12-.61l-1.92-3.32c-.12-.22-.37-.29-.59-.22l-2.39.96c-.5-.38-1.03-.7-1.62-.94l-.36-2.54c-.04-.24-.24-.41-.48-.41h-3.84c-.24 0-.43.17-.47.41l-.36 2.54c-.59.24-1.13.57-1.62.94l-2.39-.96c-.22-.08-.47 0-.59.22L2.74 8.87c-.12.21-.08.47.12.61l2.03 1.58c-.05.3-.09.63-.09.94s.02.64.07.94l-2.03 1.58c-.18.14-.23.41-.12.61l1.92 3.32c.12.22.37.29.59.22l2.39-.96c.5.38 1.03.7 1.62.94l.36 2.54c.05.24.24.41.48.41h3.84c.24 0 .44-.17.47-.41l.36-2.54c.59-.24 1.13-.56 1.62-.94l2.39.96c.22.08.47 0 .59-.22l1.92-3.32c.12-.22.07-.47-.12-.61l-2.01-1.58zM12 15.6c-1.98 0-3.6-1.62-3.6-3.6s1.62-3.6 3.6-3.6 3.6 1.62 3.6 3.6-1.62 3.6-3.6 3.6z"/></svg>
      Ajustes
    </button>
  </nav>

  <!-- MODAL: Importar / Revisar PDF -->
  <div class="sheet-overlay" id="pdfOverlay" onclick="closePdfModal()"></div>
  <div class="bottom-sheet" id="pdfSheet">
    <div class="sheet-handle"></div>
    <div class="sheet-header">
      <div>
        <h3>Importar & Revisar PDF</h3>
        <p style="font-size: 11px; color: var(--text-secondary);" id="pdfSupplierDetected">Distribuidora de Alimentos</p>
      </div>
      <button class="sheet-close" onclick="closePdfModal()">✕</button>
    </div>
    <div class="sheet-content">
      <!-- Seletor de Arquivo do iPhone -->
      <div class="upload-zone" onclick="document.getElementById('pdfInput').click()">
        <input type="file" id="pdfInput" accept="application/pdf" style="display:none;" onchange="handlePdfUpload(event)">
        <div style="font-size: 32px;">📑</div>
        <strong style="color: var(--primary-blue); font-size: 14px;">Selecionar PDF no iPhone</strong>
        <p>Toque para escolher fatura ou pedido do fornecedor</p>
      </div>

      <!-- Seletor da Loja de Destino -->
      <div style="background: white; padding: 12px; border-radius: 12px; margin-bottom: 14px; border: 0.5px solid var(--border-color); display: flex; justify-content: space-between; align-items: center;">
        <span style="font-size: 13px; font-weight: 600;">Destino dos Itens:</span>
        <select id="pdfTargetStoreSelect" style="padding: 6px 12px; border-radius: 8px; border: 1px solid var(--border-color); font-weight: 700; background: #F2F2F7; font-size: 13px;">
          <!-- Opções preenchidas dinamicamente -->
        </select>
      </div>

      <!-- Lista de Itens Extraídos -->
      <div style="font-size: 12px; font-weight: 800; color: var(--text-secondary); margin-bottom: 8px;">ITENS IDENTIFICADOS NO DOCUMENTO</div>
      <div id="pdfExtractedItemsList" style="display: flex; flex-direction: column; gap: 8px;">
        <!-- Renderizado dinamicamente com steppers de quantidade -->
      </div>
    </div>
    <div class="sheet-footer">
      <div style="display: flex; justify-content: space-between; margin-bottom: 10px;">
        <span style="color: var(--text-secondary); font-size: 13px;" id="pdfFooterSummary">0 itens</span>
        <strong style="color: var(--primary-blue); font-size: 16px;" id="pdfFooterTotal">Total: R$ 0,00</strong>
      </div>
      <button class="btn-primary" onclick="mergePdfItemsToStore()">Mesclar Itens na Lista da Loja</button>
    </div>
  </div>

  <!-- MODAL: Compartilhar / Delegar Comprador -->
  <div class="sheet-overlay" id="shareOverlay" onclick="closeShareModal()"></div>
  <div class="bottom-sheet" id="shareSheet">
    <div class="sheet-handle"></div>
    <div class="sheet-header">
      <div>
        <h3>Delegar Compradores</h3>
        <p style="font-size: 11px; color: var(--text-secondary);">Compartilhe listas com equipes no corredor</p>
      </div>
      <button class="sheet-close" onclick="closeShareModal()">✕</button>
    </div>
    <div class="sheet-content">
      <div style="margin-bottom: 12px;">
        <label style="font-size: 12px; font-weight: 700;">E-mail do Comprador:</label>
        <input type="email" id="inviteEmail" placeholder="comprador@mercado.com.br" style="width: 100%; padding: 12px; border-radius: 12px; border: 1px solid var(--border-color); margin-top: 4px; font-size: 14px;">
      </div>

      <div style="margin-bottom: 14px;">
        <label style="font-size: 12px; font-weight: 700;">Nível de Permissão:</label>
        <div style="margin-top: 6px; display: flex; flex-direction: column; gap: 8px;">
          <label style="background: white; padding: 12px; border-radius: 12px; border: 1.5px solid var(--primary-blue); display: flex; gap: 10px; align-items: center; cursor: pointer;">
            <input type="radio" name="inviteRole" value="checklist_only" checked>
            <div>
              <strong style="font-size: 13px; color: var(--primary-blue);">Apenas Checklist (Recomendado para Corredor)</strong>
              <p style="font-size: 11px; color: var(--text-secondary);">Pode marcar e desmarcar compras com ticks em tempo real.</p>
            </div>
          </label>
          <label style="background: white; padding: 12px; border-radius: 12px; border: 1px solid var(--border-color); display: flex; gap: 10px; align-items: center; cursor: pointer;">
            <input type="radio" name="inviteRole" value="editor">
            <div>
              <strong style="font-size: 13px;">Editor Completo</strong>
              <p style="font-size: 11px; color: var(--text-secondary);">Pode alterar preços, unidades e adicionar novos produtos.</p>
            </div>
          </label>
        </div>
      </div>

      <button class="btn-primary" onclick="sendBuyerInvite()">Enviar Convite In-App</button>

      <div style="font-size: 12px; font-weight: 800; color: var(--text-secondary); margin-top: 24px; margin-bottom: 8px;">COMPRADORES ATIVOS</div>
      <div id="activeMembersList" style="display: flex; flex-direction: column; gap: 8px;">
        <!-- Membros renderizados via JS -->
      </div>
    </div>
  </div>

  <!-- MODAL: Ajustes & Conformidade Apple App Store -->
  <div class="sheet-overlay" id="settingsOverlay" onclick="closeSettingsModal()"></div>
  <div class="bottom-sheet" id="settingsSheet">
    <div class="sheet-handle"></div>
    <div class="sheet-header">
      <h3>Ajustes & Conta</h3>
      <button class="sheet-close" onclick="closeSettingsModal()">✕</button>
    </div>
    <div class="sheet-content">
      <div style="background: white; padding: 16px; border-radius: 16px; border: 0.5px solid var(--border-color); display: flex; align-items: center; gap: 12px; margin-bottom: 20px;">
        <div style="width: 48px; height: 48px; border-radius: 50%; background: rgba(0, 122, 255, 0.15); display: flex; align-items: center; justify-content: center; font-size: 20px; font-weight: bold; color: var(--primary-blue);">G</div>
        <div>
          <strong style="font-size: 15px;">Gestor de Compras</strong>
          <p style="font-size: 12px; color: var(--text-secondary);">gestor@minimercado.com.br</p>
          <span style="font-size: 10px; font-weight: 800; background: #E5E5EA; padding: 2px 6px; border-radius: 6px;">ADMINISTRADOR</span>
        </div>
      </div>

      <div style="font-size: 11px; font-weight: 800; color: var(--text-secondary); margin-bottom: 8px;">APPLE APP STORE</div>
      <div style="background: white; border-radius: 14px; border: 0.5px solid var(--border-color); overflow: hidden; margin-bottom: 20px;">
        <div style="padding: 14px 16px; display: flex; justify-content: space-between; align-items: center; border-bottom: 0.5px solid var(--border-color);">
          <div style="display: flex; align-items: center; gap: 8px;">
            <span style="font-size: 18px;"></span>
            <span style="font-size: 14px; font-weight: 600;">Sign in with Apple</span>
          </div>
          <span style="color: var(--system-green); font-size: 12px; font-weight: 700;">Conectado ✓</span>
        </div>
        <div style="padding: 14px 16px; display: flex; justify-content: space-between; align-items: center;">
          <span style="font-size: 14px;">Versão do App</span>
          <span style="color: var(--text-secondary); font-size: 12px;">1.0.0 (Build 1)</span>
        </div>
      </div>

      <div style="font-size: 11px; font-weight: 800; color: var(--system-red); margin-bottom: 8px;">EXCLUSÃO DE CONTA (GUIDELINE 5.1.1)</div>
      <div style="background: white; border-radius: 14px; border: 0.5px solid #FFCDD2; padding: 14px 16px;">
        <p style="font-size: 12px; color: #555; margin-bottom: 10px;">
          Conforme exigido pelas diretrizes da Apple App Store, você pode expurgar permanentemente sua conta, todas as 6 lojas e dados dos servidores.
        </p>
        <button class="btn-danger" onclick="triggerAccountDeletion()">Excluir Minha Conta e Dados</button>
      </div>
    </div>
  </div>

  <script>
    // Estado Global da Aplicação
    const stores = [
      {{ id: 'store-1', code: 'LJ01', name: 'Centro', color: '#007AFF' }},
      {{ id: 'store-2', code: 'LJ02', name: 'Jardins', color: '#34C759' }},
      {{ id: 'store-3', code: 'LJ03', name: 'Express Norte', color: '#FF9500' }},
      {{ id: 'store-4', code: 'LJ04', name: 'Shopping Sul', color: '#AF52DE' }},
      {{ id: 'store-5', code: 'LJ05', name: 'Bairro Alto', color: '#FF2D55' }},
      {{ id: 'store-6', code: 'LJ06', name: 'Depósito Central', color: '#5856D6' }}
    ];

    let currentStoreIndex = 0;
    let isPurchasedSectionExpanded = true;

    // Itens em memória com isolamento por loja
    let items = [
      // LJ01
      {{ id: 'item-1', storeId: 'store-1', description: 'Leite Integral UHT 1L (Cx c/ 12)', quantity: 10, unit: 'cx', unitPrice: 58.80, subtotal: 588.00, isPurchased: false }},
      {{ id: 'item-2', storeId: 'store-1', description: 'Arroz Branco Nobre 5kg', quantity: 15, unit: 'pct', unitPrice: 29.90, subtotal: 448.50, isPurchased: false }},
      {{ id: 'item-3', storeId: 'store-1', description: 'Óleo de Soja 900ml (Cx c/ 20)', quantity: 8, unit: 'cx', unitPrice: 125.00, subtotal: 1000.00, isPurchased: false }},
      {{ id: 'item-4', storeId: 'store-1', description: 'Café Tradicional Torrado 500g', quantity: 20, unit: 'pct', unitPrice: 16.90, subtotal: 338.00, isPurchased: true, purchasedBy: 'Carlos' }},
      {{ id: 'item-5', storeId: 'store-1', description: 'Açúcar Cristal 5kg (Fardo c/ 6)', quantity: 5, unit: 'fd', unitPrice: 112.50, subtotal: 562.50, isPurchased: true, purchasedBy: 'Carlos' }},

      // LJ02
      {{ id: 'item-6', storeId: 'store-2', description: 'Refrigerante Cola 2L (Fardo c/ 6)', quantity: 12, unit: 'fd', unitPrice: 51.00, subtotal: 612.00, isPurchased: false }},
      {{ id: 'item-7', storeId: 'store-2', description: 'Sabão em Pó 1kg (Caixa c/ 24)', quantity: 4, unit: 'cx', unitPrice: 285.60, subtotal: 1142.40, isPurchased: false }}
    ];

    let extractedPdfData = null;

    // Inicialização da Tela
    window.addEventListener('DOMContentLoaded', () => {{
      renderStoreTabs();
      renderCurrentStore();
    }});

    function showToast(msg) {{
      const t = document.getElementById('toast');
      t.innerText = msg;
      t.classList.add('show');
      setTimeout(() => t.classList.remove('show'), 2200);
      if (window.navigator && window.navigator.vibrate) {{
        window.navigator.vibrate(15);
      }}
    }}

    function renderStoreTabs() {{
      const container = document.getElementById('storeTabs');
      const select = document.getElementById('pdfTargetStoreSelect');
      container.innerHTML = '';
      select.innerHTML = '';

      stores.forEach((store, idx) => {{
        const isActive = idx === currentStoreIndex;
        const pendingCount = items.filter(i => i.storeId === store.id && !i.isPurchased).length;

        const pill = document.createElement('div');
        pill.className = `store-pill ${{isActive ? 'active' : ''}}`;
        pill.onclick = () => selectStore(idx);
        pill.innerHTML = `
          <div class="dot" style="background: ${{store.color}}"></div>
          <strong>${{store.code}}</strong>
          <span>${{store.name}}</span>
          ${{pendingCount > 0 ? `<span class="badge">${{pendingCount}}</span>` : ''}}
        `;
        container.appendChild(pill);

        // Opção no dropdown do PDF
        const opt = document.createElement('option');
        opt.value = store.id;
        opt.innerText = `${{store.code}} - ${{store.name}}`;
        if (isActive) opt.selected = true;
        select.appendChild(opt);
      }});
    }}

    function selectStore(index) {{
      currentStoreIndex = index;
      renderStoreTabs();
      renderCurrentStore();
    }}

    function renderCurrentStore() {{
      const store = stores[currentStoreIndex];
      document.getElementById('headerStoreTitle').innerText = `${{store.code}} • ${{store.name}}`;

      const storeItems = items.filter(i => i.storeId === store.id);
      const pending = storeItems.filter(i => !i.isPurchased);
      const purchased = storeItems.filter(i => i.isPurchased);

      const totalCount = storeItems.length;
      const purchasedCount = purchased.length;
      const percentage = totalCount === 0 ? 0 : Math.round((purchasedCount / totalCount) * 100);

      // Atualizar Barra de Progresso
      const fill = document.getElementById('progressFill');
      const badge = document.getElementById('progressBadge');
      fill.style.width = `${{percentage}}%`;
      badge.innerText = `${{percentage}}% Concluído`;

      if (percentage === 100) {{
        fill.classList.add('done');
        badge.classList.add('done');
      }} else {{
        fill.classList.remove('done');
        badge.classList.remove('done');
      }}

      document.getElementById('progressCount').innerText = `${{purchasedCount}} de ${{totalCount}} itens comprados`;
      const totalBudget = storeItems.reduce((acc, i) => acc + i.subtotal, 0);
      document.getElementById('progressBudget').innerText = `Total: R$ ${{totalBudget.toFixed(2).replace('.', ',')}}`;

      // Renderizar Pendentes
      const pendingList = document.getElementById('pendingList');
      document.getElementById('pendingTitle').innerText = `A COMPRAR (${{pending.length}})`;
      pendingList.innerHTML = '';

      if (pending.length === 0) {{
        pendingList.innerHTML = `
          <div style="background: white; padding: 24px; border-radius: 14px; text-align: center; color: #8E8E93;">
            <div style="font-size: 28px; margin-bottom: 6px;">🎉</div>
            <strong style="color: #333;">Tudo Comprado nesta Loja!</strong>
            <p style="font-size: 12px; margin-top: 4px;">Importe uma fatura em PDF ou adicione novos itens.</p>
          </div>
        `;
      }} else {{
        pending.forEach(item => {{
          pendingList.appendChild(createItemElement(item, false));
        }});
      }}

      // Renderizar Comprados
      const purchasedList = document.getElementById('purchasedList');
      document.getElementById('purchasedTitle').innerText = `JÁ COMPRADOS (${{purchased.length}})`;
      purchasedList.innerHTML = '';

      if (isPurchasedSectionExpanded) {{
        purchased.forEach(item => {{
          purchasedList.appendChild(createItemElement(item, true));
        }});
      }}
    }}

    function createItemElement(item, isPurchased) {{
      const div = document.createElement('div');
      div.className = `item-tile ${{isPurchased ? 'purchased' : ''}}`;

      div.innerHTML = `
        <div class="circular-check ${{isPurchased ? 'checked' : ''}}" onclick="toggleItem('${{item.id}}')">
          ${{isPurchased ? '✓' : ''}}
        </div>
        <div class="item-info">
          <div class="item-title">${{item.description}}</div>
          <div class="item-sub">
            <span class="item-tag">${{item.quantity}} ${{item.unit}}</span>
            <span>R$ ${{item.unitPrice.toFixed(2).replace('.', ',')}} / ${{item.unit}}</span>
            ${{item.purchasedBy ? `<span>• ${{item.purchasedBy}}</span>` : ''}}
          </div>
        </div>
        <div class="item-subtotal">
          R$ ${{item.subtotal.toFixed(2).replace('.', ',')}}
        </div>
      `;
      return div;
    }}

    function toggleItem(itemId) {{
      const target = items.find(i => i.id === itemId);
      if (target) {{
        target.isPurchased = !target.isPurchased;
        target.purchasedBy = target.isPurchased ? 'Eu (iPhone)' : null;

        // Feedback sonoro/tátil nativo
        if (window.navigator && window.navigator.vibrate) {{
          window.navigator.vibrate(20);
        }}

        // Sincronizar com backend FastAPI
        fetch(`/api/v1/stores/items/${{itemId}}/toggle?buyer_name=Eu%20(iPhone)`, {{ method: 'POST' }})
          .catch(() => console.log('Offline toggle sync'));

        renderStoreTabs();
        renderCurrentStore();
        showToast(target.isPurchased ? 'Marcado como comprado!' : 'Item reativado na lista.');
      }}
    }}

    function togglePurchasedSection() {{
      isPurchasedSectionExpanded = !isPurchasedSectionExpanded;
      document.getElementById('purchasedArrow').innerText = isPurchasedSectionExpanded ? '▲' : '▼';
      renderCurrentStore();
    }}

    // Upload & Processamento do PDF
    function openPdfModal() {{
      document.getElementById('pdfOverlay').classList.add('active');
      document.getElementById('pdfSheet').classList.add('active');

      // Se ainda não tiver itens de teste, carregar um lote inicial de demonstração
      if (!extractedPdfData) {{
        loadDefaultPdfMock();
      }}
    }}

    function closePdfModal() {{
      document.getElementById('pdfOverlay').classList.remove('active');
      document.getElementById('pdfSheet').classList.remove('active');
    }}

    async function handlePdfUpload(event) {{
      const file = event.target.files[0];
      if (!file) return;

      showToast('Enviando e extraindo dados do PDF...');
      const formData = new FormData();
      formData.append('file', file);

      try {{
        const res = await fetch('/api/v1/extract-pdf', {{
          method: 'POST',
          body: formData
        }});
        if (res.ok) {{
          const data = await res.json();
          extractedPdfData = data;
          renderExtractedPdfItems();
          showToast(`Sucesso! ${{data.total_items_count}} itens identificados.`);
        }} else {{
          showToast('Erro ao ler PDF no backend. Usando modo simulador.');
          loadDefaultPdfMock();
        }}
      }} catch (err) {{
        showToast('Conectando offline: exibindo itens extraídos de amostra.');
        loadDefaultPdfMock();
      }}
    }}

    function loadDefaultPdfMock() {{
      extractedPdfData = {{
        detected_supplier: "Atacadista Distribuidor São Paulo LTDA",
        items: [
          {{ description: "Arroz Branco Nobre 5kg", quantity: 10, unit: "pct", unitPrice: 29.90, subtotal: 299.00 }},
          {{ description: "Feijão Carioca Especial 1kg", quantity: 20, unit: "un", unitPrice: 7.50, subtotal: 150.00 }},
          {{ description: "Óleo de Soja Refinado 900ml", quantity: 30, unit: "cx", unitPrice: 6.20, subtotal: 186.00 }},
          {{ description: "Leite Integral UHT 1L", quantity: 48, unit: "un", unitPrice: 4.50, subtotal: 216.00 }},
          {{ description: "Queijo Mussarela Peça", quantity: 5.5, unit: "kg", unitPrice: 38.00, subtotal: 209.00 }}
        ]
      }};
      renderExtractedPdfItems();
    }}

    function renderExtractedPdfItems() {{
      if (!extractedPdfData) return;
      document.getElementById('pdfSupplierDetected').innerText = extractedPdfData.detected_supplier || 'Fornecedor Identificado';

      const list = document.getElementById('pdfExtractedItemsList');
      list.innerHTML = '';
      let total = 0;

      extractedPdfData.items.forEach((item, idx) => {{
        total += item.subtotal;
        const row = document.createElement('div');
        row.style.cssText = 'background: white; padding: 12px; border-radius: 12px; border: 0.5px solid var(--border-color); display: flex; align-items: center; justify-content: space-between; gap: 8px;';

        row.innerHTML = `
          <div style="flex: 1; min-width: 0;">
            <strong style="font-size: 13px; display: block; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">${{item.description}}</strong>
            <span style="font-size: 11px; color: var(--text-secondary);">R$ ${{item.unitPrice.toFixed(2).replace('.', ',')}} / ${{item.unit}}</span>
          </div>
          <div class="stepper">
            <button onclick="updatePdfItemQty(${{idx}}, -1)">−</button>
            <span>${{item.quantity}}</span>
            <button onclick="updatePdfItemQty(${{idx}}, 1)">+</button>
          </div>
          <div style="font-size: 13px; font-weight: 700; color: var(--primary-blue); width: 70px; text-align: right;">
            R$ ${{item.subtotal.toFixed(2).replace('.', ',')}}
          </div>
          <button onclick="deletePdfItem(${{idx}})" style="background: none; border: none; font-size: 16px; cursor: pointer;">🗑️</button>
        `;
        list.appendChild(row);
      }});

      document.getElementById('pdfFooterSummary').innerText = `${{extractedPdfData.items.length}} itens identificados`;
      document.getElementById('pdfFooterTotal').innerText = `Total: R$ ${{total.toFixed(2).replace('.', ',')}}`;
    }}

    function updatePdfItemQty(idx, delta) {{
      const item = extractedPdfData.items[idx];
      if (item.quantity + delta >= 1) {{
        item.quantity += delta;
        item.subtotal = Math.round(item.quantity * item.unitPrice * 100) / 100;
        renderExtractedPdfItems();
      }}
    }}

    function deletePdfItem(idx) {{
      extractedPdfData.items.splice(idx, 1);
      renderExtractedPdfItems();
    }}

    function mergePdfItemsToStore() {{
      const targetStoreId = document.getElementById('pdfTargetStoreSelect').value;
      if (!extractedPdfData || extractedPdfData.items.length === 0) return;

      extractedPdfData.items.forEach(i => {{
        items.push({{
          id: 'pdf-' + Date.now() + '-' + Math.random().toString(36).substring(7),
          storeId: targetStoreId,
          description: i.description,
          quantity: i.quantity,
          unit: i.unit,
          unitPrice: i.unitPrice,
          subtotal: i.subtotal,
          isPurchased: false
        }});
      }});

      closePdfModal();
      renderStoreTabs();
      renderCurrentStore();
      showToast(`${{extractedPdfData.items.length}} itens mesclados com sucesso!`);
    }}

    // Compartilhamento In-App
    function openShareModal() {{
      document.getElementById('shareOverlay').classList.add('active');
      document.getElementById('shareSheet').classList.add('active');
      renderActiveMembers();
    }}
    function closeShareModal() {{
      document.getElementById('shareOverlay').classList.remove('active');
      document.getElementById('shareSheet').classList.remove('active');
    }}

    const members = [
      {{ name: 'Carlos Comprador', email: 'carlos@minimercado.com.br', role: 'Apenas Checklist' }},
      {{ name: 'Ana Repositora', email: 'ana@minimercado.com.br', role: 'Editor Completo' }}
    ];

    function renderActiveMembers() {{
      const list = document.getElementById('activeMembersList');
      list.innerHTML = '';
      members.forEach(m => {{
        const card = document.createElement('div');
        card.style.cssText = 'background: white; padding: 12px; border-radius: 12px; border: 0.5px solid var(--border-color); display: flex; justify-content: space-between; align-items: center;';
        card.innerHTML = `
          <div>
            <strong style="font-size: 13px;">${{m.name}}</strong>
            <p style="font-size: 11px; color: var(--text-secondary);">${{m.email}}</p>
          </div>
          <span style="font-size: 11px; font-weight: 700; color: var(--primary-blue); background: rgba(0, 122, 255, 0.1); padding: 4px 8px; border-radius: 8px;">${{m.role}}</span>
        `;
        list.appendChild(card);
      }});
    }}

    function sendBuyerInvite() {{
      const email = document.getElementById('inviteEmail').value;
      if (email && email.includes('@')) {{
        const role = document.querySelector('input[name="inviteRole"]:checked').value;
        members.push({{
          name: email.split('@')[0],
          email: email,
          role: role === 'checklist_only' ? 'Apenas Checklist' : 'Editor Completo'
        }});
        document.getElementById('inviteEmail').value = '';
        renderActiveMembers();
        showToast('Convite enviado ao comprador!');
      }} else {{
        showToast('Insira um e-mail válido.');
      }}
    }}

    // Ajustes & Exclusão de Conta (Apple Guideline 5.1.1)
    function openSettingsModal() {{
      document.getElementById('settingsOverlay').classList.add('active');
      document.getElementById('settingsSheet').classList.add('active');
    }}
    function closeSettingsModal() {{
      document.getElementById('settingsOverlay').classList.remove('active');
      document.getElementById('settingsSheet').classList.remove('active');
    }}

    function triggerAccountDeletion() {{
      if (confirm('Atenção: Deseja realmente excluir permanentemente sua conta, todas as 6 lojas e dados dos servidores? (Requisito Apple App Store)')) {{
        fetch('/api/v1/auth/delete-account', {{
          method: 'POST',
          headers: {{ 'Content-Type': 'application/json' }},
          body: JSON.stringify({{ confirm_deletion: true, reason: 'Exclusão solicitada no iPhone' }})
        }}).then(() => {{
          items = [];
          closeSettingsModal();
          renderStoreTabs();
          renderCurrentStore();
          showToast('Conta e dados excluídos permanentemente.');
        }});
      }}
    }}

    function openAddItemModal() {{
      const desc = prompt('Descrição do Produto (ex: Biscoito Cream Cracker 400g):');
      if (desc && desc.trim()) {{
        const qty = parseFloat(prompt('Quantidade:') || '1');
        const price = parseFloat(prompt('Valor Unitário R$:') || '0');
        const currentStoreId = stores[currentStoreIndex].id;

        items.push({{
          id: 'manual-' + Date.now(),
          storeId: currentStoreId,
          description: desc.trim(),
          quantity: qty,
          unit: 'un',
          unitPrice: price,
          subtotal: Math.round(qty * price * 100) / 100,
          isPurchased: false
        }});

        renderStoreTabs();
        renderCurrentStore();
        showToast('Item adicionado na lista!');
      }}
    }}
  </script>
</body>
</html>
"""
