import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import 'auth.dart';
import 'home.dart';
import 'login.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final router = RouterNotifier(ref);

  return GoRouter(
    debugLogDiagnostics: true, // For demo purposes
    refreshListenable: router, // This notifies `GoRouter` for refresh events
    redirect: router._redirectLogic, // All the logic is centralized here
    routes: router._routes, // All the routes can be found there
  );
});

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen<User?>(
      authProvider,
      (_, __) => notifyListeners(),
    );
  }

  String? _redirectLogic(GoRouterState state) {
    final loginRedirect = _loginRedirectLogic(state);
    if (loginRedirect != null) return loginRedirect;
    return null;
  }

  String? _loginRedirectLogic(GoRouterState state) {
    final areWeLoggingIn =
        state.location == state.namedLocation(LoginPage.NAME);

    final auth = _ref.read(authProvider.notifier);
    if (!auth.isLoggedIn) {
      return areWeLoggingIn ? null : state.namedLocation(LoginPage.NAME);
    } else if (areWeLoggingIn) {
      return state.namedLocation(HomePage.NAME);
    }
    return null;
  }

  List<GoRoute> get _routes => [
        GoRoute(
          name: HomePage.NAME,
          path: '/',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          name: LoginPage.NAME,
          path: '/login',
          builder: (context, _) => const LoginPage(),
        ),
      ];
}
