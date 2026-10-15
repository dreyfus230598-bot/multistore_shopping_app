import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/store_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final storeProvider = context.watch<StoreProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações & Conta'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        physics: const BouncingScrollPhysics(),
        children: [
          // Cartão de Perfil do Usuário
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: const Color(0xFF007AFF).withOpacity(0.15),
                  child: const Icon(Icons.person, size: 32, color: Color(0xFF007AFF)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        authProvider.userName,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        authProvider.userEmail,
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          authProvider.userRole.toUpperCase(),
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24.0),

          // Seção App Store & Autenticação
          _buildSectionHeader('AUTENTICAÇÃO & ACESSO'),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(14.0),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.apple, size: 28, color: Colors.black),
                  title: const Text('Sign in with Apple', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    authProvider.isSignedInWithApple
                        ? 'Vinculado com o ID Apple (Protegido)'
                        : 'Toque para vincular seu Apple ID',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: authProvider.isSignedInWithApple
                      ? const Icon(Icons.check_circle, color: Color(0xFF34C759))
                      : ElevatedButton(
                          onPressed: () => authProvider.signInWithApple(),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                          child: const Text('Conectar', style: TextStyle(color: Colors.white)),
                        ),
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.store, color: Color(0xFF007AFF)),
                  title: const Text('Lojas Vinculadas'),
                  subtitle: Text('${storeProvider.stores.length} unidades cadastradas'),
                  trailing: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24.0),

          // Seção de Privacidade e Conformidade com a Apple App Store
          _buildSectionHeader('PRIVACIDADE & CONFORMIDADE APP STORE'),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(14.0),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.shield_outlined, color: Colors.grey),
                  title: const Text('Política de Privacidade'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    _showInfoDialog(
                      context,
                      'Política de Privacidade',
                      'Este aplicativo adere estritamente às diretrizes de privacidade da Apple App Store. '
                      'Seus dados de faturas e compras são criptografados em trânsito e em repouso e não são compartilhados com terceiros.',
                    );
                  },
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.description_outlined, color: Colors.grey),
                  title: const Text('Termos de Uso do SaaS'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    _showInfoDialog(
                      context,
                      'Termos de Uso',
                      'O serviço oferece ferramentas de reposição de estoque e conferência de faturas em PDF para pequenos estabelecimentos comerciais.',
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24.0),

          // ZONA DE PERIGO: Exclusão de Conta Obrigatória pela Apple (Guideline 5.1.1(v))
          _buildSectionHeader('GERENCIAMENTO DE DADOS'),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(14.0),
              border: Border.all(color: Colors.red.shade100),
            ),
            child: ListTile(
              leading: const Icon(Icons.delete_forever, color: Color(0xFFFF3B30)),
              title: const Text(
                'Excluir Minha Conta e Dados',
                style: TextStyle(
                  color: Color(0xFFFF3B30),
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: const Text(
                'Remove permanentemente sua conta, listas de compras e todas as lojas (Requisito App Store).',
                style: TextStyle(fontSize: 12),
              ),
              trailing: const Icon(Icons.chevron_right, color: Color(0xFFFF3B30)),
              onTap: () => _confirmAccountDeletion(context),
            ),
          ),

          const SizedBox(height: 32.0),

          // Informações de Versão do App
          Center(
            child: Column(
              children: [
                Text(
                  'MultiStore Reposição SaaS',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 2),
                Text(
                  'Versão 1.0.0 (Build 1) • Pronto para App Store',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  /// Fluxo de Confirmação em 2 Etapas para Exclusão de Conta conforme App Store Guideline 5.1.1(v)
  void _confirmAccountDeletion(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Excluir Conta Definitivamente?'),
        content: const Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Text(
            'Esta ação é irreversível. Todas as suas 6 lojas, inventários, listas ativas, membros compradores delegados e dados fiscais serão permanentemente excluídos dos servidores.',
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.pop(ctx),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.pop(ctx);
              final auth = context.read<AuthProvider>();
              final success = await auth.deleteAccountPermanently(
                confirmationReason: 'Solicitado pelo usuário nas configurações do app.',
              );

              if (context.mounted && success) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (dialogCtx) => AlertDialog(
                    title: const Text('Conta Excluída com Sucesso'),
                    content: const Text(
                      'Sua conta e todos os dados associados foram expurgados permanentemente conforme as diretrizes de privacidade.',
                    ),
                    actions: [
                      ElevatedButton(
                        onPressed: () => Navigator.pop(dialogCtx),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              }
            },
            child: const Text('Sim, Excluir Definitivamente'),
          ),
        ],
      ),
    );
  }
}
