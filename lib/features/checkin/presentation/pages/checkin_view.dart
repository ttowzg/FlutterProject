import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CheckInView extends StatefulWidget {
  const CheckInView({super.key});

  @override
  State<CheckInView> createState() => _CheckInViewState();
}

class _CheckInViewState extends State<CheckInView> {
  final _codigoController = TextEditingController();
  String? _palestraSelecionadaId;
  bool _isProcessando = false;

  Future<void> _realizarCheckIn() async {
    final user = FirebaseAuth.instance.currentUser;
    // Adicionadas chaves no if para seguir o padrão de qualidade
    if (user == null || _palestraSelecionadaId == null) {
      return;
    }

    setState(() => _isProcessando = true);
    final colorScheme = Theme.of(context).colorScheme;

    try {
      final docPalestra = await FirebaseFirestore.instance
          .collection('palestras')
          .doc(_palestraSelecionadaId)
          .get();

      if (docPalestra['codigo'] == _codigoController.text.trim()) {
        // Registro da presença [cite: 124-126]
        await FirebaseFirestore.instance.collection('presencas').add({
          'userId': user.uid,
          'palestraId': _palestraSelecionadaId,
          'dataHora': FieldValue.serverTimestamp(), // Garante sincronização offline [cite: 163, 626]
          'titulo': docPalestra['titulo'],
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Check-in realizado com sucesso!"),
              backgroundColor: colorScheme.tertiary,
            ),
          );
          _codigoController.clear();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Código incorreto. Tente novamente."),
              backgroundColor: colorScheme.error,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Erro no check-in: $e");
    } finally {
      if (mounted) {
        setState(() => _isProcessando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "Selecione a atividade e insira o código fornecido pelo palestrante:",
          ),
          const SizedBox(height: 24),

          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('palestras')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const LinearProgressIndicator();
              }

              return DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Atividade",
                  border: OutlineInputBorder(),
                ),
                initialValue: _palestraSelecionadaId,
                items: snapshot.data!.docs.map((doc) {
                  return DropdownMenuItem(
                    value: doc.id,
                    child: Text(doc['titulo']),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() => _palestraSelecionadaId = val);
                },
              );
            },
          ),

          const SizedBox(height: 16),
          TextField(
            controller: _codigoController,
            decoration: const InputDecoration(
              labelText: "Código de Presença",
              prefixIcon: Icon(Icons.key),
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.characters,
          ),

          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _isProcessando ? null : _realizarCheckIn,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50), // Sua correção aplicada 
            ),
            child: _isProcessando
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text("CONFIRMAR PRESENÇA"),
          ),
        ],
      ),
    );
  }
}