# MultiStore Compras & Reposição SaaS (iOS / Android / FastAPI)

Solução móvel e backend voltada para gestão de reposição e compras em minimercados e pequenos mercados, desenvolvida para submissão pública na **Apple App Store** e **Google Play Store**.

---

## 1. Visão Geral da Arquitetura

```
multistore_shopping_app/
├── backend/                  # API FastAPI para Extração de PDFs e Sincronização
│   ├── app/
│   │   ├── api/v1/          # Endpoints versionados (/extract-pdf, /stores, /auth)
│   │   ├── schemas/         # Modelos Pydantic com validação rigorosa
│   │   ├── services/        # Motor pdfplumber com normalização R$ e tabelas
│   │   └── main.py          # Entrypoint com CORS e documentação Swagger
│   ├── tests/               # Testes unitários com PDFs sintéticos (100% aprovados)
│   └── requirements.txt
└── mobile/                   # App Flutter Nativo (Apple HIG & Material 3)
    ├── lib/
    │   ├── models/          # Store, ShoppingItem, TeamMember, PdfExtractedItem
    │   ├── providers/       # StoreProvider (Ticks, Abas, Progresso) e AuthProvider
    │   ├── screens/         # ShoppingListScreen, SettingsScreen, HomeScreen
    │   ├── services/        # ApiService com fallback offline e integração HTTP
    │   ├── theme/           # Design System iOS HIG (Cores e Tipografia Apple)
    │   └── widgets/         # CircularCheckbox, StoreTabBar, Modais de PDF e Share
    └── test/                # Testes unitários para StoreProvider e Modelos Dart
```

---

## 2. Requisitos Atendidos

### A. Navegação Multiloja
- Abas horizontais roláveis no topo da tela (`StoreTabBar`) para alternar instantaneamente entre **LJ01 a LJ06** e lojas adicionais.
- Cada loja mantém seu próprio inventário, lista ativa, histórico e orçamento isolados.
- Criação e edição dinâmica de novas unidades via diálogo in-app.

### B. Modo Compras com Tick em Tempo Real
- `CircularCheckbox` com área de toque mínima de **44x44pt** (padrão ergonômico Apple HIG para uso ágil no corredor do mercado).
- Ao tocar no item:
  - Estilo tachado (`lineThrough`) e cor atenuada.
  - Movimentação automática para a seção inferior recolhível **"JÁ COMPRADOS"**.
  - Registro de quem comprou e horário.
  - Atualização em tempo real da barra de progresso visual (percentual e contagem de itens).

### C. Importação e Cálculo de PDF
- Motor em Python (`backend/app/services/pdf_parser.py`) com detecção automática de:
  - Descrição do produto.
  - Quantidade com suporte a decimais.
  - Unidade normalizada (`un`, `cx`, `kg`, `pct`, `fd`, `l`).
  - Preço unitário e subtotal em padrão brasileiro (`R$ 1.250,50` -> `1250.50`).
  - Soma total e contagem consolidada.
- Modal de Revisão (`PdfUploadReviewModal`):
  - Ajuste inline de quantidades com recálculo automático de subtotais e valor total.
  - Exclusão de itens antes da mesclagem.
  - Seletor da loja de destino (ex: LJ01 a LJ06) antes da integração na lista ativa.

### D. Compartilhamento In-App e Conformidade com a App Store
- **Gestão de Membros (`ShareSheetModal`)**: Convite de compradores com definição estrita de permissões (*Apenas Checklist* ou *Editor Completo*).
- **Apple Sign In**: Suporte a login nativo com ID Apple.
- **Account Deletion (Guideline 5.1.1(v))**: Fluxo de exclusão permanente de conta e dados nas configurações, com diálogo de dupla confirmação e expurgo nos servidores.

---

## 3. Instruções de Execução

### Backend (FastAPI)

1. Navegue para o diretório do backend:
   ```bash
   cd backend
   ```

2. Instale as dependências:
   ```bash
   pip install -r requirements.txt
   ```

3. Execute a suíte de testes unitários:
   ```bash
   pytest tests/ -v
   ```

4. Inicie o servidor da API:
   ```bash
   uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
   ```
   Acesse a documentação interativa Swagger em: `http://localhost:8000/docs`

---

### Frontend Mobile (Flutter)

1. Navegue para o diretório mobile:
   ```bash
   cd mobile
   ```

2. Instale os pacotes:
   ```bash
   flutter pub get
   ```

3. Execute os testes unitários:
   ```bash
   flutter test
   ```

4. Execute o aplicativo em simulador iOS, Android ou Web:
   ```bash
   # Para iOS Simulator
   flutter run -d iPhone

   # Para Android Emulator
   flutter run -d android

   # Para Web / Desktop
   flutter run -d chrome
   ```

---

## 4. Guia de Submissão na Apple App Store

Para garantir aprovação rápida no processo de App Review da Apple:
1. **Guideline 5.1.1(v) - Account Deletion**: O botão "Excluir Minha Conta e Dados" está localizado em `Ajustes > Gerenciamento de Dados`, acionando confirmação e remoção no backend.
2. **Guideline 4.8 - Sign in with Apple**: O botão oficial está configurado na tela de ajustes e autenticação.
3. **Touch Targets (HIG)**: Todos os checkboxes circulares no corredor possuem padding para assegurar 44x44pt.
4. **App Privacy Details (App Store Connect)**:
   - Data Used to Track You: None.
   - Data Linked to You: Purchases, User ID, Contact Info (Email).
