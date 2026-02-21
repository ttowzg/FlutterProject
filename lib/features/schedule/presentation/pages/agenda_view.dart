import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'detalhes_palestra_page.dart';

class AgendaView extends StatelessWidget {
  const AgendaView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Se não houver usuário logado (Segurança do Requisito 5.1)
    if (user == null) {
      return const Center(child: Text("Faça login para ver sua agenda."));
    }

    return StreamBuilder<QuerySnapshot>(
      // Buscamos apenas na subcoleção do usuário logado (Alta Performance) [cite: 169-170, 444]
      stream: FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .collection('agenda')
          .orderBy('horario')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError){
          return const Center(child: Text("Erro ao carregar sua agenda."));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Caso a agenda esteja vazia (Requisito 3.1.3) [cite: 133, 636]
        if (snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.bookmark_border,
                  size: 64,
                  color: colorScheme.outline,
                ),
                const SizedBox(height: 16),
                const Text("Sua agenda está vazia."),
                const Text("Adicione palestras na aba de Programação."),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var item = snapshot.data!.docs[index];
            DateTime dataHora = (item['horario'] as Timestamp).toDate();

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          DetalhesPalestraPage(palestra: item),
                    ),
                  );
                },
                leading: CircleAvatar(
                  backgroundColor: colorScheme.secondaryContainer,
                  child: Icon(
                    Icons.event_available,
                    color: colorScheme.onSecondaryContainer,
                  ),
                ),
                title: Text(
                  item['titulo'],
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  "${item['local']} • ${DateFormat('dd/MM - HH:mm').format(dataHora)}h",
                ),
                // Botão para remover (Parte do "Gerenciar" no Requisito 3.1.3) [cite: 132, 635]
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _removerDaAgenda(context, user.uid, item.id),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Função para o usuário gerenciar a agenda excluindo itens [cite: 25, 132-133]
  Future<void> _removerDaAgenda(
    BuildContext context,
    String uid,
    String palestraId,
  ) async {
    await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(uid)
        .collection('agenda')
        .doc(palestraId)
        .delete();

    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Removido da agenda")));
    }
  }
}
