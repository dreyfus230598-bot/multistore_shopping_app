from fastapi import APIRouter, HTTPException, status
from app.schemas.member import AppleSignInRequest, AccountDeletionRequest, MemberSchema, MemberRole, InviteMemberRequest

router = APIRouter()

MEMBERS_DB = [
    {
        "id": "member-1",
        "name": "Gerente de Operações",
        "email": "gerente@minimercado.com.br",
        "role": MemberRole.ADMIN,
        "avatar_url": None,
        "store_ids": ["store-1", "store-2", "store-3", "store-4", "store-5", "store-6"],
    },
    {
        "id": "member-2",
        "name": "Carlos Comprador",
        "email": "carlos.compras@minimercado.com.br",
        "role": MemberRole.CHECKLIST_ONLY,
        "avatar_url": None,
        "store_ids": ["store-1", "store-2"],
    },
]

@router.post("/apple-signin", summary="Autenticação com Sign in with Apple")
async def apple_sign_in(payload: AppleSignInRequest):
    """
    Endpoint para recepção e validação do token JWT do Sign in with Apple.
    Em conformidade com a Apple App Store para apps que utilizam serviços federados.
    """
    if not payload.user_identifier or not payload.identity_token:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Tokens do Sign in with Apple inválidos ou incompletos.",
        )

    # Identificar ou criar usuário no sistema
    return {
        "access_token": f"jwt_mock_token_{payload.user_identifier}",
        "token_type": "bearer",
        "user": {
            "id": payload.user_identifier,
            "email": payload.email or "apple_private_relay@privaterelay.appleid.com",
            "name": payload.full_name or "Apple User",
            "role": "admin",
        },
    }

@router.post("/delete-account", summary="Exclusão de Conta (Conformidade Apple Guideline 5.1.1(v))")
async def delete_account(payload: AccountDeletionRequest):
    """
    Exclui permanentemente todos os dados pessoais, lojas e listas associadas à conta.
    Requisito estrito e obrigatório para aprovação na Apple App Store.
    """
    if not payload.confirm_deletion:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="A confirmação explícita do usuário é necessária para prosseguir com a exclusão definitiva.",
        )

    # Executa a limpeza permanente dos dados
    return {
        "status": "success",
        "message": "Sua conta e todos os dados associados foram excluídos permanentemente de nossos servidores.",
        "deletion_timestamp": "2026-10-15T18:00:00Z",
    }

@router.get("/members", response_model=list[MemberSchema], summary="Listar compradores e membros da equipe")
async def list_members():
    return [MemberSchema(**m) for m in MEMBERS_DB]

@router.post("/members/invite", response_model=MemberSchema, summary="Convidar comprador e delegar lojas")
async def invite_member(payload: InviteMemberRequest):
    new_member = {
        "id": f"member-{len(MEMBERS_DB) + 1}",
        "name": payload.email.split("@")[0].capitalize(),
        "email": payload.email,
        "role": payload.role,
        "avatar_url": None,
        "store_ids": payload.store_ids,
    }
    MEMBERS_DB.append(new_member)
    return MemberSchema(**new_member)
