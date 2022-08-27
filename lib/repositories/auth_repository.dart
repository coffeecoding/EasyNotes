import 'dart:async';

import 'network_provider.dart';

enum AuthStatus { authenticated, unauthenticated }

class AuthRepository {
  final _controller = StreamController<AuthStatus>();

  Stream<AuthStatus> get status async* {
    await Future<void>.delayed(const Duration(seconds: 1));
    yield AuthStatus.unauthenticated;
    yield* _controller.stream;
  }

  Future<void> login(
      {required String username, required String password}) async {
    try {
      _controller.add(AuthStatus.authenticated);
    } on Exception {}
  }

  logout() {
    _controller.add(AuthStatus.unauthenticated);
  }

  void dispose() => _controller.close();
}
