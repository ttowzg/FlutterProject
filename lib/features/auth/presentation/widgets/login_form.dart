import 'package:flutter/material.dart';
import '../../data/auth_service.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  void _handleLogin() async {
    final colorScheme = Theme.of(context).colorScheme;
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final user = await _authService.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (!mounted) return;

      setState(() => _isLoading = false);

      if (user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Login realizado com sucesso!"),
            backgroundColor: colorScheme.tertiary,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              "Erro ao entrar. Verifique seu e-mail acadêmico e senha.",
            ),
            backgroundColor: colorScheme.error,
          ),
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
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: "E-mail Acadêmico",
              prefixIcon: Icon(Icons.email_outlined),
              border: OutlineInputBorder(),
              hintText: "exemplo@aluno.ufop.br",
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) => (value == null || !value.contains('@'))
                ? "Insira um e-mail válido"
                : null,
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(
              labelText: "Senha",
              prefixIcon: Icon(Icons.lock_outline),
              border: OutlineInputBorder(),
            ),
            obscureText: true,
            validator: (value) => (value == null || value.length < 6)
                ? "A senha deve ter ao menos 6 caracteres"
                : null,
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("ENTRAR NO SISTEMA"),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Limpeza de recursos para evitar vazamento de memória
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
