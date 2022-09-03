import 'dart:async';

import 'network_provider.dart';

class AuthRepository {
  Future<void> login(
      {required String username, required String password}) async {
    try {
      // do login logic
      // consider catching exceptions outside instead of here
      await Future.delayed(const Duration(milliseconds: 500));
    } on Exception {}
  }

  logout() {
    // do logout logic
    // consider catching exceptions outside instead of here
  }
}
