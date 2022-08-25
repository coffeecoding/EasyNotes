import 'dart:async';

import 'package:easynotes/models/user.dart';

class UserRepository {
  User? _user;

  Future<User?> getUser() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _user;
  }
}
