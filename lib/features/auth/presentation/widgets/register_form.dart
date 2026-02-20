import 'package:flutter/material.dart';
import '../../data/auth_service.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  void _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final user = await _authService.signUp(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      // Boa prática: verifica se o widget ainda existe na tela antes de interagir com o context
      if (!mounted) return;
      setState(() => _isLoading = false);

      if (user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Conta criada com sucesso!"), backgroundColor: Colors.green),
        );
        Navigator.pop(context); // Retorna à tela de login após sucesso [cite: 472]
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erro ao cadastrar. Tente novamente."), backgroundColor: Colors.red),
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
          // Campo de E-mail com ícone para consistência [cite: 265]
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: "E-mail",
              hintText: "usuario@aluno.ufop.br",
              prefixIcon: Icon(Icons.email_outlined),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) => 
                (value == null || !value.contains('@')) ? "Insira um e-mail válido" : null,
          ),
          const SizedBox(height: 16),
          
          // Campo de Senha com ícone [cite: 265]
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(
              labelText: "Senha (mínimo 6 caracteres)",
              prefixIcon: Icon(Icons.lock_outline),
              border: OutlineInputBorder(),
            ),
            obscureText: true,
            validator: (value) => 
                (value == null || value.length < 6) ? "A senha deve ter ao menos 6 caracteres" : null,
          ),
          const SizedBox(height: 32),

          // Botão que herda o tema Vinho automaticamente [cite: 461, 544]
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
}