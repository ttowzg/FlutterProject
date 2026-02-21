import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class GestaoGradeView extends StatefulWidget {
  const GestaoGradeView({super.key});

  @override
  State<GestaoGradeView> createState() => _GestaoGradeViewState();
}

class _GestaoGradeViewState extends State<GestaoGradeView> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _localController = TextEditingController();
  final _resumoController = TextEditingController();
  DateTime? _dataSelecionada;
  TimeOfDay? _horaSelecionada;
  String? _uidPalestranteSelecionado;
  String? _nomePalestranteSelecionado;

  Future<void> _selecionarData(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2026),
      lastDate: DateTime(2027),
    );
    if (picked != null) setState(() => _dataSelecionada = picked);
  }

  Future<void> _selecionarHora(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) setState(() => _horaSelecionada = picked);
  }

  Future<void> _salvarPalestra() async {
    if (!_formKey.currentState!.validate() || 
        _dataSelecionada == null || 
        _horaSelecionada == null || 
        _uidPalestranteSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Preencha todos os campos e selecione o palestrante.")),
      );
      return;
    }

    final DateTime horarioCompleto = DateTime(
      _dataSelecionada!.year,
      _dataSelecionada!.month,
      _dataSelecionada!.day,
      _horaSelecionada!.hour,
      _horaSelecionada!.minute,
    );

    try {
      // 1. Cria a palestra
      await FirebaseFirestore.instance.collection('palestras').add({
        'titulo': _tituloController.text,
        'local': _localController.text,
        'resumo': _resumoController.text,
        'horario': Timestamp.fromDate(horarioCompleto),
        'palestrante': _nomePalestranteSelecionado,
        'uidPalestrante': _uidPalestranteSelecionado,
      });

      // 2. Atualiza o papel do usuário para palestrante
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(_uidPalestranteSelecionado)
          .update({'role': 'palestrante'});

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Palestra criada e palestrante designado!")),
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro: $e")));
    }
  }

  void _abrirModalCadastro() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20, right: 20, top: 20,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Nova Palestra", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextFormField(controller: _tituloController, decoration: const InputDecoration(labelText: "Título")),
                  TextFormField(controller: _localController, decoration: const InputDecoration(labelText: "Local")),
                  TextFormField(controller: _resumoController, decoration: const InputDecoration(labelText: "Resumo/Descrição"), maxLines: 3),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await _selecionarData(context);
                            setModalState(() {});
                          },
                          icon: const Icon(Icons.calendar_today),
                          label: Text(_dataSelecionada == null ? "Data" : DateFormat('dd/MM/yy').format(_dataSelecionada!)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await _selecionarHora(context);
                            setModalState(() {});
                          },
                          icon: const Icon(Icons.access_time),
                          label: Text(_horaSelecionada == null ? "Hora" : _horaSelecionada!.format(context)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text("Selecionar Palestrante:", style: TextStyle(fontWeight: FontWeight.bold)),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('usuarios').snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const CircularProgressIndicator();
                      var users = snapshot.data!.docs;
                      return DropdownButtonFormField<String>(
                        value: _uidPalestranteSelecionado,
                        items: users.map((u) {
                          return DropdownMenuItem(
                            value: u.id,
                            child: Text(u['nome'] ?? 'Sem nome'),
                          );
                        }).toList(),
                        onChanged: (val) {
                          var userDoc = users.firstWhere((u) => u.id == val);
                          setModalState(() {
                            _uidPalestranteSelecionado = val;
                            _nomePalestranteSelecionado = userDoc['nome'];
                          });
                        },
                        decoration: const InputDecoration(hintText: "Escolha um usuário"),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _salvarPalestra,
                    style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                    child: const Text("CRIAR PALESTRA"),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('palestras').orderBy('horario').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          var palestras = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: palestras.length,
            itemBuilder: (context, index) {
              var p = palestras[index];
              return Card(
                child: ListTile(
                  title: Text(p['titulo']),
                  subtitle: Text("${p['palestrante']} - ${DateFormat('dd/MM HH:mm').format(p['horario'].toDate())}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => FirebaseFirestore.instance.collection('palestras').doc(p.id).delete(),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirModalCadastro,
        child: const Icon(Icons.add),
      ),
    );
  }
}
