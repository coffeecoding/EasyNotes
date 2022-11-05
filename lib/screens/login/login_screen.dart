import 'package:easynotes/blocs/auth/auth_bloc.dart';
import 'package:easynotes/config/constants.dart';
import 'package:easynotes/extensions/color_ext.dart';
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
  _LoginScreenState() : _pageController = PageController(initialPage: 1);
  PageController _pageController;

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
          child: Column(children: [
            Expanded(
              flex: 1,
              child: Row(children: [
                Expanded(flex: 1, child: Container()),
                Expanded(
                  flex: 4,
                  child: Container(
                    alignment: Alignment.center,
                    child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 200),
                        child: const Image(image: AssetImage(logoPath3x))),
                  ),
                ),
                Expanded(flex: 1, child: Container()),
              ]),
            ),
            Expanded(
              flex: 2,
              child: Row(children: [
                Expanded(
                    flex: 1,
                    child: Center(
                        child: false
                            ? Container()
                            : InkWell(
                                onTap: () => Future.delayed(
                                        const Duration(milliseconds: 0),
                                        () => _pageController.previousPage(
                                            duration: const Duration(
                                                milliseconds: 150),
                                            curve: Curves.ease))
                                    .then((_) => setState(() {})),
                                child: const Icon(
                                  Icons.chevron_left,
                                  size: 64,
                                  color: Colors.white30,
                                ),
                              ))),
                Expanded(
                  flex: 4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 4,
                        child: PageView(
                            onPageChanged: (p) {
                              print(p);
                              Future.delayed(const Duration(milliseconds: 400),
                                  () => setState(() {}));
                            },
                            controller: _pageController,
                            scrollBehavior: AppScrollBehavior(),
                            children: <Widget>[
                              const Center(
                                child: Text(
                                    textAlign: TextAlign.center,
                                    maxLines: null,
                                    'Made by Yousuf from yscodes.com\n\nThis app is free and ad-free.\nPlease consider supporting:\nhttps://easynotes.app/donate'),
                              ),
                              LoginForm(pageController: _pageController),
                              SignupForm(pageController: _pageController)
                            ]),
                      ),
                    ],
                  ),
                ),
                Expanded(
                    flex: 1,
                    child: Center(
                        child: false
                            ? Container()
                            : InkWell(
                                onTap: () => Future.delayed(
                                        const Duration(milliseconds: 0),
                                        () => _pageController.nextPage(
                                            duration: const Duration(
                                                milliseconds: 150),
                                            curve: Curves.ease))
                                    .then((_) => setState(() {})),
                                child: const Icon(
                                  Icons.chevron_right,
                                  size: 64,
                                  color: Colors.white30,
                                ),
                              ))),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}
