import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

final firebaseAuthProvider =
    Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);


final idTokenProvider = StateNotifierProvider<IdTokenService, String?>((ref) {
  return IdTokenService(
    ref.read,
    ref.watch(firebaseAuthProvider),
  );
});

final authProvider = StateNotifierProvider<AuthService, User?>((ref) {
  return AuthService(ref.watch(firebaseAuthProvider));
});

class IdTokenService extends StateNotifier<String?> {
  final Reader _read;
  final FirebaseAuth _instance;
  late StreamSubscription _idTokenChanges;

  IdTokenService(Reader read, FirebaseAuth instance)
      : _read = read,
        _instance = instance,
        super(null) {
    _idTokenChanges = _instance
        .idTokenChanges()
        .listen(onData);
  }

  void onData(User? user) async {
    try {
      state = await user?.getIdToken();
    } on FirebaseException catch (e) {
      rethrow;
    }
  }

  void dispose() {
    super.dispose();
    _idTokenChanges.cancel();
  }
}

class AuthService extends StateNotifier<User?> {
  final FirebaseAuth _instance;
  // fires when user signed in, signed out, listener registered
  late StreamSubscription _authStateChanges;

  AuthService(FirebaseAuth instance)
      : _instance = instance,
        super(null) {
    state = _instance.currentUser;
    _authStateChanges = _instance
        .authStateChanges()
        .listen((User? user) => state = user);
  }

  void dispose() {
    super.dispose();
    _authStateChanges.cancel();
  }

  bool get isLoggedIn {
    return state != null;
  }

  Future<String?> get userId async {
    if (isLoggedIn) return state!.uid;
    return null;
  }

  Future<void> signOut() async {
    await _instance.signOut();
  }
}
