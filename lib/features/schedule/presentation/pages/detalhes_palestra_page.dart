import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class DetalhesPalestraPage extends StatelessWidget {
  final QueryDocumentSnapshot palestra;

  const DetalhesPalestraPage({super.key, required this.palestra});

  // Lógica para salvar na subcoleção e verificar conflitos
  Future<void> _gerenciarAgenda(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final colorScheme = Theme.of(context).colorScheme;
    final agendaRef = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid)
        .collection('agenda');

    try {
      // 1. Verifica se a palestra já está na agenda para evitar processamento desnecessário
      final jaExiste = await agendaRef.doc(palestra.id).get();
      if (jaExiste.exists && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Esta atividade já está na sua agenda!"),
          ),
        );
        return;
      }

      // 2. Verifica Conflito de Horário (Requisito 3.1.3 - Cenário Alternativo)
      final conflitos = await agendaRef
          .where('horario', isEqualTo: palestra['horario'])
          .get();

      if (conflitos.docs.isNotEmpty && context.mounted) {
        final palestraConflitante = conflitos.docs.first;
        final nomeConflito = palestraConflitante['titulo'];

        // Diálogo simplificado: Apenas Cancelar ou Substituir [cite: 642]
        bool? substituir = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Conflito de Horário"),
            content: Text(
              "Você já salvou '$nomeConflito' para este horário. Deseja substituí-la por esta nova atividade?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("MANTER ANTIGA"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("SUBSTITUIR"),
              ),
            ],
          ),
        );

        if (substituir != true) return;

        // Se confirmou a substituição, removemos o registro conflitante
        await agendaRef.doc(palestraConflitante.id).delete();
      }

      // 3. Gravação na Subcoleção 'agenda' [cite: 545, 721]
      await agendaRef.doc(palestra.id).set({
        'idPalestra': palestra.id,
        'titulo': palestra['titulo'],
        'horario': palestra['horario'],
        'local': palestra['local'],
        'palestrante': palestra['palestrante'],
        'resumo': palestra['resumo'],
        'adicionadoEm': FieldValue.serverTimestamp(),
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Agenda atualizada!"),
            backgroundColor:
                colorScheme.tertiary, // Verde sucesso institucional
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erro: $e"),
            backgroundColor: colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final DateTime dataHora = (palestra['horario'] as Timestamp).toDate();

    return Scaffold(
      appBar: AppBar(title: const Text("Detalhes")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              palestra['titulo'] ?? "Sem título",
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            _buildInfoRow(
              Icons.person,
              "Palestrante",
              palestra['palestrante'],
              colorScheme,
            ),
            _buildInfoRow(
              Icons.location_on,
              "Local",
              palestra['local'],
              colorScheme,
            ),
            _buildInfoRow(
              Icons.access_time,
              "Horário",
              "${DateFormat('dd/MM - HH:mm').format(dataHora)}h",
              colorScheme,
            ),

            const Divider(height: 40),

            Text(
              "Sobre a atividade",
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              palestra['resumo'] ?? "Sem resumo disponível.",
              style: textTheme.bodyLarge?.copyWith(height: 1.5),
              textAlign: TextAlign.justify,
            ),

            const SizedBox(height: 40),

            // BOTÃO DE AÇÃO [cite: 134, 409, 640]
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => _gerenciarAgenda(context),
                icon: const Icon(Icons.bookmark_add),
                label: const Text("ADICIONAR À MINHA AGENDA"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    ColorScheme colorScheme,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: colorScheme.secondary),
          const SizedBox(width: 12),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: "$label: ",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
