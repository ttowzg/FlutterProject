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

      // 2. Verifica Conflito de Horário (Requisito 3.1.3 - Restrição de Horário Robusta)
      // Buscamos toda a agenda para comparar horários de forma flexível (ignorando segundos)
      final todasAsPalestras = await agendaRef.get();
      final novaData = (palestra['horario'] as Timestamp).toDate();

      for (var doc in todasAsPalestras.docs) {
        final dataExistente = (doc['horario'] as Timestamp).toDate();

        // Compara se o dia e o horário (hora/minuto) são idênticos
        bool mesmoDiaEHorario = dataExistente.year == novaData.year &&
            dataExistente.month == novaData.month &&
            dataExistente.day == novaData.day &&
            dataExistente.hour == novaData.hour &&
            dataExistente.minute == novaData.minute;

        if (mesmoDiaEHorario && context.mounted) {
          final nomeConflito = doc['titulo'];

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Conflito de Horário: Você já possui '$nomeConflito' agendada para este mesmo horário.",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: colorScheme.error,
              duration: const Duration(seconds: 4),
            ),
          );
          return; // Interrompe o cadastro
        }
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

            // NOVA SEÇÃO: PERGUNTAS E RESPOSTAS
            SecaoPerguntas(palestraId: palestra.id),
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

// Widget para gerenciar a interação de Perguntas [cite: 132, 400-405]
class SecaoPerguntas extends StatefulWidget {
  final String palestraId;

  const SecaoPerguntas({super.key, required this.palestraId});

  @override
  State<SecaoPerguntas> createState() => _SecaoPerguntasState();
}

class _SecaoPerguntasState extends State<SecaoPerguntas> {
  final TextEditingController _controller = TextEditingController();
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;

  Future<void> _enviarPergunta() async {
    final texto = _controller.text.trim();
    if (texto.isEmpty || _uid == null) return;

    final user = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance
        .collection('palestras')
        .doc(widget.palestraId)
        .collection('perguntas')
        .add({
      'texto': texto,
      'autor': user?.displayName ?? "Estudante",
      'uidAutor': _uid,
      'horario': FieldValue.serverTimestamp(),
    });

    _controller.clear();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pergunta enviada com sucesso!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('usuarios').doc(_uid).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        final role = snapshot.data?.get('role') ?? 'aluno';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(height: 60),
            Row(
              children: [
                Icon(Icons.question_answer, color: colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  "Perguntas e Respostas",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Interface do ALUNO: Campo para perguntar
            if (role == 'aluno') ...[
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: "Faça uma pergunta ao palestrante...",
                  filled: true,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send),
                    color: colorScheme.primary,
                    onPressed: _enviarPergunta,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 32),
            ],

            // Lista de Perguntas (Exibição Dinâmica)
            Text(
              role == 'palestrante' ? "Perguntas Recebidas" : "Minhas Perguntas",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('palestras')
                  .doc(widget.palestraId)
                  .collection('perguntas')
                  .orderBy('horario', descending: true)
                  .snapshots(),
              builder: (context, qSnapshot) {
                if (qSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: LinearProgressIndicator());
                }

                final perguntas = qSnapshot.data?.docs ?? [];
                
                // Filtra perguntas: Aluno só vê as suas, Palestrante vê todas
                final listaFiltrada = perguntas.where((p) {
                  if (role == 'palestrante') return true;
                  return p['uidAutor'] == _uid;
                }).toList();

                if (listaFiltrada.isEmpty) {
                  return Text(
                    "Nenhuma pergunta enviada ainda.",
                    style: TextStyle(color: colorScheme.outline, fontStyle: FontStyle.italic),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: listaFiltrada.length,
                  itemBuilder: (context, index) {
                    final p = listaFiltrada[index];
                    return Card(
                      elevation: 0,
                      color: colorScheme.surfaceVariant.withOpacity(0.5),
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(p['texto']),
                        subtitle: Text(
                          "Por: ${p['autor']} • ${p['horario'] != null ? DateFormat('HH:mm').format((p['horario'] as Timestamp).toDate()) : ''}",
                          style: const TextStyle(fontSize: 12),
                        ),
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
  }
}
