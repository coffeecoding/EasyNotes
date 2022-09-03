import 'package:easynotes/repositories/auth_repository.dart';
import 'package:easynotes/repositories/item_repository.dart';
import 'package:easynotes/repositories/network_provider.dart';
import 'package:easynotes/repositories/preference_repository.dart';
import 'package:get_it/get_it.dart';

/// Global [GetIt.instance]
final GetIt locator = GetIt.instance;

/// Set up [GetIt] locator
Future<void> setUpLocator() async {
  locator
    ..registerSingleton<AuthRepository>(AuthRepository())
    ..registerSingleton<PreferenceRepository>(PreferenceRepository())
    ..registerSingleton<ItemRepository>(ItemRepository())
    ..registerSingleton<NetworkProvider>(NetworkProvider());
}
