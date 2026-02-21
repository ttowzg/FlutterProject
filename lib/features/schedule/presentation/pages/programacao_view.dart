import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'detalhes_palestra_page.dart';

class ProgramacaoView extends StatelessWidget {
  const ProgramacaoView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return StreamBuilder<QuerySnapshot>(
      // Apontando para a coleção 'palestras' conforme alinhamos
      stream: FirebaseFirestore.instance
          .collection('palestras')
          .orderBy('horario')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text("Erro ao carregar."));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("Nenhuma palestra encontrada."));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var palestra = snapshot.data!.docs[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: colorScheme.primary,
                  child: const Icon(Icons.event, color: Colors.white),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          DetalhesPalestraPage(palestra: palestra),
                    ),
                  );
                },
                title: Text(palestra['titulo'], style: textTheme.titleMedium),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(
                            text: "Palestrante: ",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: "${palestra['palestrante']}"),
                        ],
                      ),
                    ),
                    Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(
                            text: "Local: ",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: "${palestra['local']}"),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        // Exibe: 24/02/2026
                        Text(
                          DateFormat(
                            'dd/MM/yyyy',
                          ).format(palestra['horario'].toDate()),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        // Exibe: 19:00h
                        Text(
                          "${DateFormat('HH:mm').format(palestra['horario'].toDate())}h",
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
