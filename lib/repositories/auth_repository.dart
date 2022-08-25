import 'dart:async';

enum AuthStatus { authenticated, unauthenticated }

class AuthenticationRepository {
  final _controller = StreamController<AuthStatus>();

  Stream<AuthStatus> get status async* {
    await Future<void>.delayed(const Duration(seconds: 1));
    yield AuthStatus.unauthenticated;
    yield* _controller.stream;
  }

  Future<void> login(
      {required String username, required String passwordHash}) async {
    await Future.delayed(
      const Duration(milliseconds: 500),
      () => _controller.add(AuthStatus.authenticated),
    );
  }

  logout() {
    _controller.add(AuthStatus.unauthenticated);
  }

  void dispose() => _controller.close();
}
