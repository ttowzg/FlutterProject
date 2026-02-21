import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app_semana_computacao/shared/widgets/nav_bar.dart';
import '../../../schedule/presentation/pages/programacao_view.dart';
import '../../../profile/presentation/pages/profile_view.dart';
import '../../../schedule/presentation/pages/agenda_view.dart';
import '../../../checkin/presentation/pages/checkin_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _indiceAtual = 0;
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('usuarios').doc(_uid).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));

        final String role = snapshot.data?.get('role') ?? 'aluno';

        // Lógica de telas baseada no papel [cite: 352, 460-462]
        final List<Widget> views = [const ProgramacaoView()];
        if (role == 'aluno') {
          views.addAll([const AgendaView(), const CheckInView()]);
        } else if (role == 'palestrante') {
          views.add(const Center(child: Text("Painel de Perguntas")));
        } else if (role == 'organizador') {
          views.add(const Center(child: Text("Gestão da Grade")));
        }
        views.add(const ProfileView());

        if (_indiceAtual >= views.length) _indiceAtual = 0;

        return Scaffold(
          appBar: AppBar(title: const Text("Semana da Computação"), centerTitle: true),
          body: IndexedStack(index: _indiceAtual, children: views), // Responsividade < 1s [cite: 167, 442]
          bottomNavigationBar: NavBar(
            selectedIndex: _indiceAtual,
            role: role,
            onDestinationSelected: (index) => setState(() => _indiceAtual = index),
          ),
        );
      },
    );
  }
}