import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. Monitorar o estado do usuário (se está logado ou não)
  Stream<User?> get userStatus => _auth.authStateChanges();

  // 2. Criar conta (Cadastro) - Requisito 3.1.1
  Future<User?> signUp(String email, String password, String nome) async {
  try {
    UserCredential result = await _auth.createUserWithEmailAndPassword(
      email: email, 
      password: password
    );
    
    User? user = result.user;

    if (user != null) {
      // Cria o documento do usuário com o papel de Aluno por padrão
      await _db.collection('usuarios').doc(user.uid).set({
        'nome': nome,
        'email': email,
        'role': 'aluno', // Use a constante aqui se preferir
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    return user;
  } catch (e) {
    debugPrint("Erro no cadastro: ${e.toString()}");
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
      debugPrint("Erro no login: ${e.toString()}");
      return null;
    }
  }

  // 4. Sair (Logout)
  Future<void> signOut() async {
    await _auth.signOut();
  }
}