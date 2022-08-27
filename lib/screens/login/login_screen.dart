import 'package:easynotes/blocs/auth/auth_bloc.dart';
import 'package:easynotes/config/constants.dart';
import 'package:easynotes/main.dart';
import 'package:easynotes/repositories/auth_repository.dart';
import 'package:easynotes/screens/common/app_scroll_behaviour.dart';
import 'package:easynotes/screens/login/views/views.dart';
import 'package:easynotes/screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  static const String routeName = '/login';

  static Route<dynamic> route() {
    return MaterialPageRoute<LoginScreen>(
      settings: const RouteSettings(name: routeName),
      builder: (BuildContext context) => const LoginScreen(),
    );
  }

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _pageController = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          EasyNotesApp.navigatorKey.currentState!
              .pushAndRemoveUntil(HomeScreen.route(), (route) => false);
        }
      },
      child: Material(
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.only(left: 64, right: 64, top: 92),
                child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: const Image(image: AssetImage(logoPath3x))),
              ),
              Expanded(
                flex: 4,
                child: PageView(
                    controller: _pageController,
                    scrollBehavior: AppScrollBehavior(),
                    children: <Widget>[
                      LoginForm(pageController: _pageController),
                      SignupForm(pageController: _pageController)
                    ]),
              ),
              Expanded(flex: 1, child: Container())
            ],
          ),
        ),
      ),
    );
  }
}
