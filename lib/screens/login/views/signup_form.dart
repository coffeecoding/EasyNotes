import 'package:easynotes/screens/common/responsive.dart';
import 'package:flutter/material.dart';

class SignupForm extends StatelessWidget {
  const SignupForm({Key? key, required this.pageController}) : super(key: key);

  final PageController pageController;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: Responsive.isDesktop(context)
                  ? 92
                  : Responsive.isTablet(context)
                      ? 64
                      : 32),
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
                  onPressed: () => pageController.animateToPage(0,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.ease),
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
