import 'package:easynotes/main.dart';
import 'package:easynotes/repositories/auth_repository.dart';
import 'package:easynotes/screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/blocs.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  static const String routeName = '/splash';

  static Route<dynamic> route() {
    return MaterialPageRoute<SplashScreen>(
      settings: const RouteSettings(name: routeName),
      builder: (BuildContext context) => const SplashScreen(),
    );
  }

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          switch (state.status) {
            case AuthStatus.authenticated:
              EasyNotesApp.navigatorKey.currentState!
                  .pushAndRemoveUntil(HomeScreen.route(), (route) => false);
              break;
            case AuthStatus.unauthenticated:
              EasyNotesApp.navigatorKey.currentState!
                  .pushAndRemoveUntil(LoginScreen.route(), (route) => false);
              break;
          }
        },
        child: const Center(child: Text('Splashing')));
  }
}
