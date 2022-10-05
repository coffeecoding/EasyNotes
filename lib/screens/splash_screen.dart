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
    final bloc = context.read<AuthBloc>();
    final authstate = bloc.state.status;
    print(authstate);
    if (authstate == AuthStatus.authenticated) {
      return HomeScreen();
    } else {
      return const LoginScreen();
    }
  }
}
