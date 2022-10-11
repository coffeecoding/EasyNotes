import 'package:easynotes/config/locator.dart';
import 'package:easynotes/cubits/cubits.dart';
import 'package:easynotes/repositories/auth_repository.dart';
import 'package:easynotes/repositories/item_repository.dart';
import 'package:easynotes/repositories/preference_repository.dart';
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
                  preferenceRepository: locator.get<PreferenceRepository>(),
                  itemRepository: locator.get<ItemRepository>())),
          BlocProvider<ItemsCubit>(
              lazy: false,
              create: (context) =>
                  ItemsCubit(itemRepo: locator.get<ItemRepository>())),
        ],
        child: MaterialApp(
          title: 'EasyNotes',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            visualDensity: VisualDensity.adaptivePlatformDensity,
            brightness: Brightness.dark,
            primarySwatch: Colors.purple,
          ),
          themeMode: ThemeMode.light,
          navigatorKey: navigatorKey,
          onGenerateRoute: CustomRouter.onGenerateRoute,
          initialRoute: SplashScreen.routeName,
        ));
  }
}
