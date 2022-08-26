import 'package:easynotes/repositories/auth_repository.dart';
import 'package:easynotes/repositories/dio_repository.dart';
import 'package:easynotes/repositories/user_repository.dart';
import 'package:get_it/get_it.dart';

/// Global [GetIt.instance]
final GetIt locator = GetIt.instance;

/// Set up [GetIt] locator
Future<void> setUpLocator() async {
  locator
    ..registerSingleton<UserRepository>(UserRepository())
    ..registerSingleton<AuthRepository>(AuthRepository())
    ..registerSingleton<DioRepository>(DioRepository());
}
