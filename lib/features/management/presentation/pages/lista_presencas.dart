import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ListaPresencasPage extends StatelessWidget {
  final String palestraId;
  final String tituloPalestra;

  const ListaPresencasPage({
    super.key,
    required this.palestraId,
    required this.tituloPalestra,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text("Presenças: $tituloPalestra")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('presencas')
            .where('palestraId', isEqualTo: palestraId)
            .orderBy('dataHora', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off, size: 64, color: colorScheme.outline),
                  const SizedBox(height: 16),
                  const Text("Nenhum check-in realizado ainda."),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              var data = doc.data() as Map<String, dynamic>;

              String identificacao =
                  data.containsKey('nomeAluno') && data['nomeAluno'] != null
                  ? data['nomeAluno']
                  : "ID: ${data['userId']?.toString().substring(0, 8) ?? 'Desconhecido'}";

              return Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(
                    identificacao,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text("Participação confirmada"),
                  trailing: const Icon(Icons.verified, color: Colors.green),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
