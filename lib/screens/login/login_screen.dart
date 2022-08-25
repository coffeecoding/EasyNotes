import 'package:easynotes/config/constants.dart';
import 'package:easynotes/screens/common/app_scroll_behaviour.dart';
import 'package:easynotes/screens/login/views/views.dart';
import 'package:flutter/material.dart';

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
  final _pageController = PageController(initialPage: 1);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        child: Container(
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
