import 'package:easynotes/repositories/auth_repository.dart';
import 'package:easynotes/repositories/item_repository.dart';
//import 'package:easynotes/repositories/mock_item_repo.dart';
import 'package:easynotes/services/crypto_service.dart';
import 'package:easynotes/services/network_provider.dart';
import 'package:easynotes/repositories/preference_repository.dart';
import 'package:get_it/get_it.dart';

/// Global [GetIt.instance]
final GetIt locator = GetIt.instance;

/// Set up [GetIt] locator
Future<void> setUpLocator() async {
  locator
    ..registerSingleton<PreferenceRepository>(PreferenceRepository())
    ..registerSingleton<NetworkProvider>(NetworkProvider())
    ..registerSingleton<AuthRepository>(AuthRepository())
    ..registerSingleton<CryptoService>(CryptoService())
    ..registerSingleton<ItemRepository>(ItemRepo());
}
