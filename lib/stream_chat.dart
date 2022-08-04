import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stream_chat_bug/other_api.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

import 'auth.dart';

const String YOUR_API_KEY = 'INSERT API KEY';

final streamChatClientProvider = Provider((ref) {
  return StreamChatClient(
    YOUR_API_KEY,
    logLevel: Level.WARNING,
  );
});

final streamChatUserProvider =
    StateNotifierProvider<StreamChatUserRepository, AsyncValue<OwnUser?>>(
        (ref) {
  // ! Watching the idTokenProvider is necessary to trigger the bugs
  // We need this in our original repo to get a token to fetch the chat token
  final a = ref.watch(idTokenProvider);
  final api = ref.watch(otherApiProvider);

  return StreamChatUserRepository(ref.read, ref.watch(authProvider.notifier),
      ref.watch(streamChatClientProvider), api);
});

class StreamChatUserRepository extends StateNotifier<AsyncValue<OwnUser?>> {
  Reader _read;
  AuthService _auth;
  StreamChatClient _client;
  BackendAPINew _api;

  StreamChatUserRepository(read, auth, client, api)
      : _read = read,
        _auth = auth,
        _client = client,
        _api = api,
        super(AsyncValue.loading()) {
    refresh();
  }

  void refresh() async {
    state = AsyncLoading();
    if (_auth.isLoggedIn) {
      state = await AsyncValue.guard(() async => await connectUser());
    } else {
      await AsyncValue.guard(() async => await _client.disconnectUser());
      // push notifications: await chatClient.removeDevice(id, user_id)
      state = AsyncData(null);
    }
  }

  Future<String> getChatToken() async {
    final response = await _api.getChatToken((await _auth.userId)!);
    return jsonDecode(response.body)['token'];
  }

  Future<OwnUser> connectUser() async {
    final token = await getChatToken();
    final user = User(id: (await _auth.userId)!);
    return _client.connectUser(
      user,
      token,
    );
  }
}

final unreadChannelsRepositoryProvider =
    StateNotifierProvider<UnreadChannelsRepository, AsyncValue<int?>>((ref) {
  return UnreadChannelsRepository(
      ref.watch(streamChatUserProvider), ref.watch(streamChatClientProvider));
});

class UnreadChannelsRepository extends StateNotifier<AsyncValue<int?>> {
  StreamChatClient _client;
  late StreamSubscription _unreadChannelsChanges;

  UnreadChannelsRepository(AsyncValue<OwnUser?> user, StreamChatClient client)
      : _client = client,
        super(AsyncValue.loading()) {
    initialiseUnreadChannels(user);
    listenToChangesInUnreadChannels();
  }

  @override
  void dispose() {
    _unreadChannelsChanges.cancel();
    super.dispose();
  }

  void initialiseUnreadChannels(AsyncValue<OwnUser?> user) {
    state = user.when(
        data: (user) => AsyncData(user == null ? null : user.unreadChannels),
        loading: () => AsyncValue.loading(),
        error: (err, stack) => AsyncError(err, stackTrace: stack));
  }

  void listenToChangesInUnreadChannels() {
    _unreadChannelsChanges = _client
        .on()
        .where((event) => event.unreadChannels != null && event.user != null)
        .listen((event) {
      state = AsyncData(event.unreadChannels);
    });
  }
}
