from typing import Optional
from enum import Enum
from pydantic import BaseModel, Field

class MemberRole(str, Enum):
    CHECKLIST_ONLY = "checklist_only"  # Apenas marcar e desmarcar itens no corredor
    EDITOR = "editor"                  # Pode criar, editar produtos e alterar preços
    ADMIN = "admin"                    # Acesso total, incluindo adicionar compradores

class MemberSchema(BaseModel):
    id: str
    name: str
    email: str
    role: MemberRole
    avatar_url: Optional[str] = None
    store_ids: list[str] = Field(default_factory=list)

class InviteMemberRequest(BaseModel):
    email: str
    role: MemberRole = MemberRole.CHECKLIST_ONLY
    store_ids: list[str] = Field(default_factory=list)

class AppleSignInRequest(BaseModel):
    identity_token: str
    authorization_code: str
    user_identifier: str
    email: Optional[str] = None
    full_name: Optional[str] = None

class AccountDeletionRequest(BaseModel):
    confirm_deletion: bool
    reason: Optional[str] = None
