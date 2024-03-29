import 'package:easynotes/blocs/auth/auth_bloc.dart';
import 'package:easynotes/cubits/cubits.dart';
import 'package:easynotes/screens/common/responsive.dart';
import 'package:easynotes/screens/common/uiconstants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginForm extends StatelessWidget {
  LoginForm({Key? key, required this.pageController}) : super(key: key);

  final PageController pageController;
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

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
                controller: usernameController,
                onChanged: (username) {},
                decoration:
                    const InputDecoration(labelText: 'Username or Email'),
              ),
              const SizedBox(height: ConstSpacing.m),
              TextField(
                controller: passwordController,
                obscureText: true,
                onChanged: (password) {},
                decoration: const InputDecoration(labelText: 'Password'),
              ),
              const SizedBox(height: ConstSpacing.xl),
              BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
                switch (state.status) {
                  case AuthStatus.error:
                    return const Text('Something went wrong ...',
                        style: TextStyle(color: Colors.red));
                  default:
                    return const Text('');
                }
              }),
              const SizedBox(height: ConstSpacing.xl),
              BlocBuilder<AuthBloc, AuthState>(
                buildWhen: (prev, next) => prev.status != next.status,
                builder: (context, state) {
                  switch (state.status) {
                    case AuthStatus.waiting:
                      return const SizedBox(
                          height: 40, child: CircularProgressIndicator());
                    default:
                      return ElevatedButton(
                          onPressed: () {
                            context.read<AuthBloc>().add(AuthLoginRequested(
                                usernameController.text,
                                passwordController.text,
                                context.read<RootItemsCubit>()));
                          },
                          child: Container(
                              width: double.infinity,
                              height: 40,
                              child: const Center(child: Text('Login'))));
                  }
                },
              ),
              const SizedBox(height: ConstSpacing.m),
              ElevatedButton(
                  onPressed: () => pageController.animateToPage(1,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.ease),
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
