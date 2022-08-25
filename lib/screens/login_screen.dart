import 'package:easynotes/config/constants.dart';
import 'package:easynotes/screens/common/app_scroll_behaviour.dart';
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

class LoginForm extends StatelessWidget {
  const LoginForm({Key? key, required this.pageController}) : super(key: key);

  final PageController pageController;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 64),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                onChanged: (username) {},
                decoration:
                    const InputDecoration(labelText: 'Username or Email'),
              ),
              const SizedBox(height: 12),
              TextField(
                onChanged: (password) {},
                decoration: const InputDecoration(labelText: 'Password'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (_) => const AlertDialog(content: Text('hi')));
                  },
                  child: Container(
                      width: double.infinity,
                      height: 40,
                      child: const Center(child: Text('Login')))),
              const SizedBox(height: 12),
              ElevatedButton(
                  onPressed: () => pageController
                      .jumpTo(pageController.position.maxScrollExtent),
                  style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).cardColor,
                      textStyle: const TextStyle(color: Colors.white)),
                  child: Container(
                      width: double.infinity,
                      height: 40,
                      child: Center(
                          child: Text('Create Account',
                              style: TextStyle(
                                  fontWeight: Theme.of(context)
                                      .primaryTextTheme
                                      .bodyText1!
                                      .fontWeight,
                                  color: Colors.white))))),
            ],
          ),
        ),
      ),
    );
  }
}

class SignupForm extends StatelessWidget {
  const SignupForm({Key? key, required this.pageController}) : super(key: key);

  final PageController pageController;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 64),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                onChanged: (username) {},
                decoration: const InputDecoration(
                    labelText: 'Username (must be unique)'),
              ),
              const SizedBox(height: 12),
              TextField(
                onChanged: (email) {},
                decoration: const InputDecoration(labelText: 'Email Address'),
              ),
              const SizedBox(height: 12),
              TextField(
                onChanged: (password) {},
                decoration: const InputDecoration(labelText: 'Password'),
              ),
              const SizedBox(height: 12),
              TextField(
                onChanged: (password) {},
                decoration:
                    const InputDecoration(labelText: 'Confirm Password'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (_) => const AlertDialog(content: Text('hi')));
                  },
                  child: Container(
                      width: double.infinity,
                      height: 40,
                      child: const Center(child: Text('Sign Up')))),
              const SizedBox(height: 12),
              ElevatedButton(
                  onPressed: () => pageController
                      .jumpTo(pageController.position.minScrollExtent),
                  style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).cardColor,
                      textStyle:
                          TextStyle(color: Theme.of(context).primaryColor)),
                  child: Container(
                      width: double.infinity,
                      height: 40,
                      child: Center(
                          child: Text('Back to Login',
                              style: TextStyle(
                                  fontWeight: Theme.of(context)
                                      .primaryTextTheme
                                      .bodyText1!
                                      .fontWeight,
                                  color: Colors.white))))),
            ],
          ),
        ),
      ),
    );
  }
}
