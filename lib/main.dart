import 'package:easynotes/config/locator.dart';
import 'package:easynotes/repositories/auth_repository.dart';
import 'package:easynotes/repositories/user_repository.dart';
import 'package:easynotes/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'blocs/blocs.dart';
import 'config/custom_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setUpLocator();

  runApp(const EasyNotesApp());
}

class EasyNotesApp extends StatelessWidget {
  const EasyNotesApp({super.key});

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: <BlocProvider<dynamic>>[
          BlocProvider<AuthBloc>(
              lazy: false,
              create: (context) => AuthBloc(
                  authRepository: locator.get<AuthRepository>(),
                  userRepository: locator.get<UserRepository>()))
        ],
        child: MaterialApp(
          title: 'EasyNotes',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.purple,
          ),
          themeMode: ThemeMode.light,
          navigatorKey: navigatorKey,
          onGenerateRoute: CustomRouter.onGenerateRoute,
          initialRoute: SplashScreen.routeName,
        ));
  }
}
