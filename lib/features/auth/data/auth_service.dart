import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1. Monitorar o estado do usuário (se está logado ou não)
  Stream<User?> get userStatus => _auth.authStateChanges();

  // 2. Criar conta (Cadastro) - Requisito 3.1.1
  Future<User?> signUp(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );
      return result.user;
    } catch (e) {
      print("Erro no cadastro: ${e.toString()}");
      return null;
    }
  }

  // 3. Fazer Login - Item 3.1 da EAP
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );
      return result.user;
    } catch (e) {
      print("Erro no login: ${e.toString()}");
      return null;
    }
  }

  // 4. Sair (Logout)
  Future<void> signOut() async {
    await _auth.signOut();
  }
}