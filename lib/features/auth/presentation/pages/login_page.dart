import 'package:app_semana_computacao/features/auth/presentation/pages/register_page.dart';
import 'package:flutter/material.dart';
import '../widgets/login_form.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Acesso dinâmico ao tema para garantir consistência visual (Requisito 3.11)
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 80),
              
              // Logo institucional do ICEA/UFOP (Requisito 3.12 / Padrões de Interface)
              Image.asset(
                'assets/images/logo_icea.png', 
                height: 120,
              ),
              
              const SizedBox(height: 16),
              
              Text(
                "Semana da Computação",
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary, // Aplica o Vinho oficial
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                "Entre para gerenciar sua agenda e fazer check-in",
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.secondary, // Aplica o Cinza oficial
                ),
              ),
              
              const SizedBox(height: 40),

              // Widget de formulário desacoplado (Seguindo a estrutura da EAP)
              const LoginForm(),
              
              const SizedBox(height: 16),

              // Navegação para cadastro usando as cores do tema
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterPage(),
                    ),
                  );
                },
                child: Text(
                  "Não tem uma conta? Cadastre-se aqui",
                  style: TextStyle(
                    color: colorScheme.primary, // Herda o Vinho automaticamente
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}