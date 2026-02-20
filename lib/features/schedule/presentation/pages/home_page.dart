import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../auth/data/auth_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Programação Oficial"),
        centerTitle: true,
        // Botão de Logout para testes de acesso (EAP 3.1)
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Sair",
            onPressed: () => authService.signOut(),
          ),
        ],
      ),
      // StreamBuilder: Ouve o Firestore em tempo real (Requisito 3.4.1)
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('atividades')
            .orderBy('horario') // Ordena por data/hora
            .snapshots(),
        builder: (context, snapshot) {
          // 1. Tratamento de Erro
          if (snapshot.hasError) {
            return const Center(child: Text("Erro ao carregar programação."));
          }

          // 2. Estado de Carregamento (Meta: < 5s)
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 3. Lista Vazia
          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Nenhuma palestra cadastrada."));
          }

          // 4. Exibição da Lista de Palestras (Requisito 3.9.1)
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var palestra = snapshot.data!.docs[index];
              
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: colorScheme.primary,
                    child: const Icon(Icons.event, color: Colors.white),
                  ),
                  title: Text(
                    palestra['titulo'] ?? "Sem título",
                    style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text("🎙️ ${palestra['palestrante']}"),
                      Text("📍 ${palestra['local']}"),
                      const SizedBox(height: 4),
                      // Formatação simples do horário
                      Text(
                        "⏰ ${palestra['horario'].toDate().toString().substring(11, 16)}h",
                        style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Futuro: Navegar para detalhes e Check-in (Requisito 3.1.1)
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}