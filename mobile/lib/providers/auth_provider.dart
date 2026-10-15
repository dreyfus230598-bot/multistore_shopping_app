import 'package:flutter/material.dart';
import '../models/team_member.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool _isAuthenticated = true; // Simulado para experiência imediata
  bool _isSignedInWithApple = true;
  String _userName = 'Gestor de Compras';
  String _userEmail = 'gestor@minimercado.com.br';
  String _userRole = 'admin';

  final List<TeamMember> _members = [
    TeamMember(
      id: 'member-1',
      name: 'Gestor de Compras',
      email: 'gestor@minimercado.com.br',
      role: MemberRole.admin,
      assignedStoreIds: ['store-1', 'store-2', 'store-3', 'store-4', 'store-5', 'store-6'],
    ),
    TeamMember(
      id: 'member-2',
      name: 'Carlos Comprador',
      email: 'carlos.compras@minimercado.com.br',
      role: MemberRole.checklistOnly,
      assignedStoreIds: ['store-1', 'store-2'],
    ),
    TeamMember(
      id: 'member-3',
      name: 'Ana Repositora',
      email: 'ana.estoque@minimercado.com.br',
      role: MemberRole.editor,
      assignedStoreIds: ['store-3', 'store-4'],
    ),
  ];

  bool get isAuthenticated => _isAuthenticated;
  bool get isSignedInWithApple => _isSignedInWithApple;
  String get userName => _userName;
  String get userEmail => _userEmail;
  String get userRole => _userRole;
  List<TeamMember> get members => List.unmodifiable(_members);

  /// Executa o fluxo de autenticação com o Apple ID
  Future<void> signInWithApple() async {
    // Simulação do fluxo nativo do Apple Sign In
    await Future.delayed(const Duration(milliseconds: 600));
    _isAuthenticated = true;
    _isSignedInWithApple = true;
    _userName = 'Comprador Apple';
    _userEmail = 'apple_id_user@privaterelay.appleid.com';
    notifyListeners();
  }

  /// Convidar novo comprador com papel definido (Checklist Only ou Editor)
  void inviteMember({
    required String email,
    required MemberRole role,
    required List<String> storeIds,
  }) {
    final newMember = TeamMember(
      id: 'member-${DateTime.now().millisecondsSinceEpoch}',
      name: email.split('@').first.toUpperCase(),
      email: email,
      role: role,
      assignedStoreIds: storeIds,
    );
    _members.add(newMember);
    notifyListeners();
  }

  /// Exclusão Definitiva de Conta - Requisito Mandatório Apple App Store (Guideline 5.1.1(v))
  Future<bool> deleteAccountPermanently({required String confirmationReason}) async {
    final success = await _apiService.deleteAccount(reason: confirmationReason);
    if (success) {
      _isAuthenticated = false;
      _isSignedInWithApple = false;
      _userName = '';
      _userEmail = '';
      _members.clear();
      notifyListeners();
    }
    return success;
  }
}
