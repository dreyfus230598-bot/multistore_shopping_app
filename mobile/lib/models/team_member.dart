enum MemberRole {
  checklistOnly, // Pode apenas marcar ticks no corredor do mercado
  editor,        // Pode editar produtos, criar e excluir itens
  admin,         // Controle total da loja
}

extension MemberRoleExtension on MemberRole {
  String get label {
    switch (this) {
      case MemberRole.checklistOnly:
        return 'Apenas Checklist';
      case MemberRole.editor:
        return 'Editor Completo';
      case MemberRole.admin:
        return 'Administrador';
    }
  }

  String get description {
    switch (this) {
      case MemberRole.checklistOnly:
        return 'Ideal para compradores no corredor do mercado. Permite dar check e desmarcar.';
      case MemberRole.editor:
        return 'Permite adicionar itens, ajustar preços, alterar quantidades e categorias.';
      case MemberRole.admin:
        return 'Acesso total para gerenciar lojas, orçamentos e convidar membros.';
    }
  }

  static MemberRole fromString(String val) {
    switch (val.toLowerCase()) {
      case 'checklist_only':
        return MemberRole.checklistOnly;
      case 'editor':
        return MemberRole.editor;
      case 'admin':
      default:
        return MemberRole.admin;
    }
  }

  String toApiString() {
    switch (this) {
      case MemberRole.checklistOnly:
        return 'checklist_only';
      case MemberRole.editor:
        return 'editor';
      case MemberRole.admin:
        return 'admin';
    }
  }
}

class TeamMember {
  final String id;
  final String name;
  final String email;
  final MemberRole role;
  final String? avatarUrl;
  final List<String> assignedStoreIds;

  TeamMember({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.avatarUrl,
    required this.assignedStoreIds,
  });

  factory TeamMember.fromJson(Map<String, dynamic> json) {
    return TeamMember(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: MemberRoleExtension.fromString(json['role'] as String? ?? 'checklist_only'),
      avatarUrl: json['avatar_url'] as String?,
      assignedStoreIds: (json['store_ids'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}
