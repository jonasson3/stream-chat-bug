import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stream_chat_bug/other_api.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

import 'auth.dart';
import 'stream_chat.dart';

class HomePage extends ConsumerWidget {
  static const NAME = 'HOME';
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider.notifier);

    // If includeMatchesIcon==false, no issues
    // If includeMatchesIcon==true get issues when pushing Update followed by Sign Out
    const includeMatchesIcon = true; 
    final newButton = TextButton(
        child: const Text('Update'),
        onPressed: () async =>
            ref.read(otherApiProvider).update((await auth.userId)!));
    final signOutButton = TextButton(
        child: const Text('Signout'),
        onPressed: () async => await ref.read(authProvider.notifier).signOut());

    final children = <Widget>[signOutButton, newButton];
    if (includeMatchesIcon) {
      final unreadChannels = ref.watch(unreadChannelsRepositoryProvider);
      final matchesIcon = unreadChannels.when(
          data: (data) {
            return Badge(
                child: Icon(Icons.chat_bubble),
                elevation: 0,
                showBadge: data != 0 && data != null,
                badgeContent: data == null
                    ? null
                    : Text(data.toString(), style: TextStyle(fontSize: 11)));
          },
          loading: () => Icon(Icons.chat_bubble),
          error: (err, st) => Icon(Icons.chat_bubble));
      children.add(matchesIcon);
    }
    return SafeArea(child: Scaffold(body: Column(children: children)));
  }
}
