import 'package:flutter/material.dart';

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
