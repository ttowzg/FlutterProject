import 'package:app_semana_computacao/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'features/auth/data/auth_service.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/main/presentation/pages/home_page.dart';
import 'features/schedule/presentation/pages/gestao_grade_view.dart';
import 'features/speakers/presentation/pages/painel_perguntas_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Semana da Computação - ICEA',
      theme: AppTheme.lightTheme,
      // O segredo está aqui: o StreamBuilder decide qual ecrã mostrar
      home: StreamBuilder<User?>(
        stream: AuthService().userStatus,
        builder: (context, snapshot) {
          // Se snapshot tem dados, o utilizador está logado
          if (snapshot.hasData) {
            return const HomePage();
          }
          // Se não, volta para o login
          return const LoginPage();
        },
      ),
    );
  }
}


