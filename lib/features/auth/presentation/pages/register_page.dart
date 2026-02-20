import 'package:flutter/material.dart';
import '../widgets/register_form.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Buscamos o esquema de cores do tema que você configurou no main.dart
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      // O AppBar usará automaticamente a cor primária (Vinho) ou o tema definido
      appBar: AppBar(
        title: const Text("Criar Conta"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // REMOVIDO 'const' aqui para permitir o uso de colorScheme
              Icon(
                Icons.person_add_alt_1,
                size: 80,
                color: colorScheme.primary, // Aplica o Vinho da UFOP
              ),
              const SizedBox(height: 24),
              Text(
                "Cadastre-se para participar das atividades",
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.secondary, // Aplica o Cinza oficial
                ),
              ),
              const SizedBox(height: 40),
              
              // Widget do formulário que você já criou
              const RegisterForm(),
              
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Já tem uma conta? Voltar para o Login",
                  style: TextStyle(color: colorScheme.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}