import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class PainelPerguntasView extends StatelessWidget {
  const PainelPerguntasView({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        // Busca apenas palestras onde o usuário atual é o palestrante
        stream: FirebaseFirestore.instance
            .collection('palestras')
            .where('uidPalestrante', isEqualTo: uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Erro ao buscar palestras."));
          }

          final palestras = snapshot.data?.docs ?? [];
          if (palestras.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text(
                  "Você ainda não possui palestras atribuídas.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: palestras.length,
            separatorBuilder: (context, index) => const Divider(height: 32),
            itemBuilder: (context, index) {
              final p = palestras[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.event_note, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          p['titulo'],
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Perguntas Recebidas:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  
                  // Sub-lista de perguntas para esta palestra
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('palestras')
                        .doc(p.id)
                        .collection('perguntas')
                        .orderBy('horario', descending: true)
                        .snapshots(),
                    builder: (context, qSnapshot) {
                      if (!qSnapshot.hasData) return const LinearProgressIndicator();

                      final perguntas = qSnapshot.data!.docs;
                      if (perguntas.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text("Nenhuma pergunta para esta palestra ainda.", 
                                      style: TextStyle(fontStyle: FontStyle.italic)),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: perguntas.length,
                        itemBuilder: (context, pIndex) {
                          final pergunta = perguntas[pIndex];
                          final data = (pergunta['horario'] as Timestamp?)?.toDate();
                          
                          return Card(
                            elevation: 0,
                            color: colorScheme.surfaceVariant.withOpacity(0.3),
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text(pergunta['texto']),
                              subtitle: Text(
                                "Enviado por: ${pergunta['autor']} • ${data != null ? DateFormat('HH:mm').format(data) : ''}",
                                style: const TextStyle(fontSize: 12),
                              ),
                              trailing: Icon(Icons.mark_chat_unread, 
                                            size: 16, color: colorScheme.secondary),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
