import 'package:easynotes/blocs/auth/auth_bloc.dart';
import 'package:easynotes/cubits/login/login_cubit.dart';
import 'package:easynotes/repositories/auth_repository.dart';
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
          padding: const EdgeInsets.symmetric(horizontal: 64),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: usernameController,
                onChanged: (username) {},
                decoration:
                    const InputDecoration(labelText: 'Username or Email'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passwordController,
                obscureText: true,
                onChanged: (password) {},
                decoration: const InputDecoration(labelText: 'Password'),
              ),
              const SizedBox(height: 24),
              BlocBuilder<LoginCubit, LoginState>(
                builder: (context, state) {
                  switch (state.status) {
                    case LoginStatus.submitting:
                      return const SizedBox(
                          height: 40, child: CircularProgressIndicator());
                    default:
                      return ElevatedButton(
                          onPressed: () => context
                              .read<LoginCubit>()
                              .loginWithCredentials(usernameController.text,
                                  passwordController.text)
                              .then((value) => context.read<AuthBloc>().add(
                                  const AuthStateChanged(
                                      AuthStatus.authenticated))),
                          child: Container(
                              width: double.infinity,
                              height: 40,
                              child: const Center(child: Text('Login'))));
                  }
                },
              ),
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
