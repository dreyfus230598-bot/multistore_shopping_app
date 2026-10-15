import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/store_provider.dart';
import '../models/team_member.dart';

class ShareSheetModal extends StatefulWidget {
  const ShareSheetModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const ShareSheetModal(),
    );
  }

  @override
  State<ShareSheetModal> createState() => _ShareSheetModalState();
}

class _ShareSheetModalState extends State<ShareSheetModal> {
  final TextEditingController _emailController = TextEditingController();
  MemberRole _selectedRole = MemberRole.checklistOnly;
  final Set<String> _selectedStores = {};

  @override
  void initState() {
    super.initState();
    final storeProvider = context.read<StoreProvider>();
    if (storeProvider.stores.isNotEmpty) {
      _selectedStores.add(storeProvider.currentStore.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final storeProvider = context.watch<StoreProvider>();
    final members = authProvider.members;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      child: Column(
        children: [
          // Drag Handle
          Container(
            margin: const EdgeInsets.only(top: 10.0, bottom: 6.0),
            width: 40.0,
            height: 4.5,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Compartilhar & Delegar Lista',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.4,
                      ),
                    ),
                    Text(
                      'Convide compradores para atuar no mercado',
                      style: TextStyle(fontSize: 12.0, color: Colors.grey),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  style: IconButton.styleFrom(backgroundColor: Colors.grey.shade200),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20.0),
              children: [
                // Formulário de Convite
                const Text(
                  'Convidar Novo Comprador',
                  style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10.0),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'comprador@mercado.com.br',
                    prefixIcon: const Icon(Icons.mail_outline, size: 20),
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ),

                const SizedBox(height: 16.0),
                const Text(
                  'Permissão de Acesso',
                  style: TextStyle(fontSize: 13.0, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8.0),

                // Seletor de Papéis (Checklist Only vs Editor)
                _buildRoleOption(
                  role: MemberRole.checklistOnly,
                  title: 'Apenas Checklist (Recomendado para Corredor)',
                  subtitle: 'Pode visualizar a lista e marcar itens como comprados em tempo real.',
                ),
                const SizedBox(height: 8.0),
                _buildRoleOption(
                  role: MemberRole.editor,
                  title: 'Editor Completo',
                  subtitle: 'Pode alterar preços, unidades e adicionar/remover produtos da lista.',
                ),

                const SizedBox(height: 16.0),
                const Text(
                  'Lojas Autorizadas',
                  style: TextStyle(fontSize: 13.0, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8.0),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: storeProvider.stores.map((s) {
                    final isChecked = _selectedStores.contains(s.id);
                    return FilterChip(
                      selected: isChecked,
                      label: Text('${s.code} - ${s.name}'),
                      selectedColor: s.color.withOpacity(0.2),
                      checkmarkColor: s.color,
                      labelStyle: TextStyle(
                        color: isChecked ? s.color : Colors.black87,
                        fontWeight: isChecked ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                      onSelected: (val) {
                        setState(() {
                          if (val) {
                            _selectedStores.add(s.id);
                          } else {
                            _selectedStores.remove(s.id);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20.0),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007AFF),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 46),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.send_rounded, size: 18),
                  label: const Text('Enviar Convite'),
                  onPressed: () {
                    final email = _emailController.text.trim();
                    if (email.isNotEmpty && email.contains('@')) {
                      authProvider.inviteMember(
                        email: email,
                        role: _selectedRole,
                        storeIds: _selectedStores.toList(),
                      );
                      _emailController.clear();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Convite enviado com sucesso!'),
                          backgroundColor: Color(0xFF34C759),
                        ),
                      );
                    }
                  },
                ),

                const SizedBox(height: 24.0),
                const Text(
                  'Equipe com Acesso',
                  style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10.0),

                // Lista de Membros Atuais
                ...members.map((member) => Container(
                      margin: const EdgeInsets.only(bottom: 8.0),
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: const Color(0xFF007AFF).withOpacity(0.15),
                            child: Text(
                              member.name.substring(0, 1).toUpperCase(),
                              style: const TextStyle(
                                color: Color(0xFF007AFF),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  member.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                Text(
                                  member.email,
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: member.role == MemberRole.checklistOnly
                                  ? const Color(0xFF34C759).withOpacity(0.15)
                                  : const Color(0xFF007AFF).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              member.role.label,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: member.role == MemberRole.checklistOnly
                                    ? const Color(0xFF34C759)
                                    : const Color(0xFF007AFF),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleOption({
    required MemberRole role,
    required String title,
    required String subtitle,
  }) {
    final isSelected = _selectedRole == role;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedRole = role;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF007AFF).withOpacity(0.06) : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF007AFF) : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Radio<MemberRole>(
              value: role,
              groupValue: _selectedRole,
              onChanged: (val) {
                if (val != null) setState(() => _selectedRole = val);
              },
              activeColor: const Color(0xFF007AFF),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? const Color(0xFF007AFF) : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
