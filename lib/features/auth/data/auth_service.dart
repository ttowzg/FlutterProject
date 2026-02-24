import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get userStatus => _auth.authStateChanges();

  Future<User?> signUp(String email, String password, String nome) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      if (user != null) {
        await _db.collection('usuarios').doc(user.uid).set({
          'nome': nome,
          'email': email,
          'role': 'aluno',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return user;
    } catch (e) {
      debugPrint("Erro no cadastro: ${e.toString()}");
      return null;
    }
  }

  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      debugPrint("Erro no login: ${e.toString()}");
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
