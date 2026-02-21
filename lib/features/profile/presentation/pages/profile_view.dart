import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../auth/data/auth_service.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final authService = AuthService();
    final colorScheme = Theme.of(context).colorScheme;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('usuarios').doc(user?.uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final userData = snapshot.data?.data() as Map<String, dynamic>?;

        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const CircleAvatar(
                radius: 50,
                child: Icon(Icons.person, size: 50),
              ),
              const SizedBox(height: 24),
              // Exibe o Nome (Requisito US4) [cite: 352, 650]
              ListTile(
                title: const Text("Nome"),
                subtitle: Text(userData?['nome'] ?? "Não informado"),
                leading: const Icon(Icons.badge_outlined),
              ),
              ListTile(
                title: const Text("E-mail"),
                subtitle: Text(user?.email ?? "Não informado"),
                leading: const Icon(Icons.email_outlined),
              ),
              // Exibe o Papel (Role) para conferência [cite: 104-107]
              ListTile(
                title: const Text("Tipo de Conta"),
                subtitle: Text(userData?['role']?.toUpperCase() ?? "ALUNO"),
                leading: const Icon(Icons.admin_panel_settings_outlined),
              ),
              const Spacer(),
              // Botão de Logout para resolver o seu problema [cite: 461, 719]
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => authService.signOut(),
                  icon: const Icon(Icons.logout),
                  label: const Text("SAIR DA CONTA"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.error,
                    side: BorderSide(color: colorScheme.error),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}