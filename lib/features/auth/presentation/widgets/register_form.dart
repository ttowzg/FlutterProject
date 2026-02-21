import 'package:flutter/material.dart';
import '../../data/auth_service.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController(); // Novo controlador
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  void _handleRegister() async {
    final colorScheme = Theme.of(context).colorScheme;
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Agora passamos o nome para o método signUp
      final user = await _authService.signUp(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _nomeController.text.trim(), // Enviando o nome
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text("Conta criada com sucesso!"), backgroundColor: colorScheme.tertiary),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text("Erro ao cadastrar. Tente novamente."), backgroundColor: colorScheme.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // NOVO: Campo de Nome Completo
          TextFormField(
            controller: _nomeController,
            decoration: const InputDecoration(
              labelText: "Nome Completo",
              prefixIcon: Icon(Icons.person_outline),
              border: OutlineInputBorder(),
            ),
            validator: (value) => (value == null || value.isEmpty) ? "Insira seu nome" : null,
          ),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: "E-mail Acadêmico",
              prefixIcon: Icon(Icons.email_outlined),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) => (value == null || !value.contains('@')) ? "E-mail inválido" : null,
          ),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(
              labelText: "Senha (mín. 6 caracteres)",
              prefixIcon: Icon(Icons.lock_outline),
              border: OutlineInputBorder(),
            ),
            obscureText: true,
            validator: (value) => (value == null || value.length < 6) ? "Senha muito curta" : null,
          ),
          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleRegister,
              child: _isLoading 
                ? const CircularProgressIndicator(color: Colors.white) 
                : const Text("CADASTRAR CONTA"),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}