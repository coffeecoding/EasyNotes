import 'package:easynotes/config/locator.dart';
import 'package:easynotes/cubits/cubits.dart';
import 'package:easynotes/cubits/search/search_cubit.dart';
import 'package:easynotes/cubits/signup/signup_cubit.dart';
import 'package:easynotes/cubits/trashed_items/trashed_items_cubit.dart';
import 'package:easynotes/repositories/abstract_item_repository.dart';
import 'package:easynotes/repositories/auth_repository.dart';
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
          BlocProvider<ChildrenItemsCubit>(
            lazy: false,
            create: (context) =>
                ChildrenItemsCubit(itemRepo: locator.get<ItemRepository>()),
          ),
          BlocProvider<TrashedItemsCubit>(
            lazy: false,
            create: (context) =>
                TrashedItemsCubit(itemRepo: locator.get<ItemRepository>()),
          ),
          BlocProvider<RootItemsCubit>(
              lazy: false,
              create: (context) => RootItemsCubit(
                    itemRepo: locator.get<ItemRepository>(),
                    trashedItemsCubit:
                        BlocProvider.of<TrashedItemsCubit>(context),
                    childrenItemsCubit:
                        BlocProvider.of<ChildrenItemsCubit>(context),
                  )),
          BlocProvider<SelectedNoteCubit>(
              lazy: false,
              create: (context) => SelectedNoteCubit(
                  childrenItemsCubit:
                      BlocProvider.of<ChildrenItemsCubit>(context))),
          BlocProvider<TopicCubit>(
              lazy: false, create: (context) => TopicCubit(null)),
          BlocProvider<SearchCubit>(
              lazy: false, create: (context) => SearchCubit()),
          BlocProvider<PreferenceCubit>(
              lazy: false,
              create: (context) => PreferenceCubit(
                  prefsRepo: locator.get<PreferenceRepository>(),
                  authRepo: locator.get<AuthRepository>())),
          BlocProvider<SignupCubit>(
            lazy: false,
            create: (context) =>
                SignupCubit(authRepo: locator.get<AuthRepository>()),
          )
        ],
        child: MaterialApp(
          title: 'EasyNotes',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            visualDensity: VisualDensity.adaptivePlatformDensity,
            brightness: Brightness.dark,
            primaryColor: Colors.blue,
            primarySwatch: Colors.blue,
          ),
          themeMode: ThemeMode.light,
          navigatorKey: navigatorKey,
          onGenerateRoute: CustomRouter.onGenerateRoute,
          initialRoute: SplashScreen.routeName,
        ));
  }
}
