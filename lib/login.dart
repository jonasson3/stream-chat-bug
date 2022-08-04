import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterfire_ui/auth.dart';

class LoginPage extends ConsumerWidget {
  static const NAME = 'login';

  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const SignInScreen(
      providerConfigs: [EmailProviderConfiguration()],
    );
  }
}
