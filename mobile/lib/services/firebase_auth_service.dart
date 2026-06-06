// Autenticação de clientes com Firebase Authentication (e-mail/senha).
//
// Os dados extras do cadastro (nome e telefone) são guardados na coleção
// "usuarios" do Cloud Firestore, identificados pelo uid da conta, seguindo a
// abordagem apresentada na disciplina.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Erro de autenticação já traduzido para uma mensagem amigável ao usuário.
class AuthFalha implements Exception {
  final String mensagem;
  AuthFalha(this.mensagem);

  @override
  String toString() => mensagem;
}

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Usuário autenticado no momento (null se ninguém estiver logado).
  User? get usuarioAtual => _auth.currentUser;

  /// Notifica login/logout para que a interface reaja automaticamente.
  Stream<User?> get mudancasDeAutenticacao => _auth.authStateChanges();

  Future<void> entrar({required String email, required String senha}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: senha);
    } on FirebaseAuthException catch (e) {
      throw AuthFalha(_mensagemPara(e.code));
    }
  }

  Future<void> cadastrar({
    required String nome,
    required String email,
    required String telefone,
    required String senha,
  }) async {
    try {
      final credencial = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );

      final usuario = credencial.user;
      if (usuario == null) {
        throw AuthFalha('Não foi possível concluir o cadastro.');
      }

      await usuario.updateDisplayName(nome);

      // Guarda as informações adicionais no Firestore (coleção "usuarios").
      await _firestore.collection('usuarios').doc(usuario.uid).set({
        'uid': usuario.uid,
        'nome': nome,
        'email': email,
        'telefone': telefone,
        'criado_em': FieldValue.serverTimestamp(),
      });
    } on FirebaseAuthException catch (e) {
      throw AuthFalha(_mensagemPara(e.code));
    }
  }

  Future<void> recuperarSenha(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthFalha(_mensagemPara(e.code));
    }
  }

  Future<void> sair() => _auth.signOut();

  /// Recupera o nome do usuário logado: usa o displayName e, se necessário,
  /// busca o documento correspondente na coleção "usuarios" do Firestore.
  Future<String> nomeDoUsuarioLogado() async {
    final usuario = _auth.currentUser;
    if (usuario == null) return '';

    final nomeLocal = usuario.displayName;
    if (nomeLocal != null && nomeLocal.isNotEmpty) return nomeLocal;

    final doc = await _firestore.collection('usuarios').doc(usuario.uid).get();
    return (doc.data()?['nome'] as String?) ?? (usuario.email ?? '');
  }

  String _mensagemPara(String code) {
    switch (code) {
      case 'invalid-email':
        return 'O formato do e-mail é inválido.';
      case 'user-not-found':
        return 'Não encontramos uma conta com este e-mail.';
      case 'wrong-password':
        return 'Senha incorreta.';
      case 'invalid-credential':
        return 'E-mail ou senha incorretos.';
      case 'user-disabled':
        return 'Esta conta foi desativada.';
      case 'email-already-in-use':
        return 'Este e-mail já está cadastrado.';
      case 'weak-password':
        return 'A senha precisa ter pelo menos 6 caracteres.';
      case 'too-many-requests':
        return 'Muitas tentativas. Aguarde um momento e tente novamente.';
      case 'network-request-failed':
        return 'Falha de conexão. Verifique sua internet.';
      default:
        return 'Não foi possível concluir a operação. ($code)';
    }
  }
}
