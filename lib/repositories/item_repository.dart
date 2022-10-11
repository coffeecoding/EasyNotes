import 'package:easynotes/config/locator.dart';
import 'package:easynotes/models/item.dart';
import 'package:easynotes/models/sample_data.dart';

import '../services/network_provider.dart';
import 'preference_repository.dart';

class ItemRepository {
  ItemRepository()
      : netClient = locator.get<NetworkProvider>(),
        prefsRepo = locator.get<PreferenceRepository>();

  late NetworkProvider netClient;
  late PreferenceRepository prefsRepo;

  List<Item> items = <Item>[];

  // This
  Future<List<Item>> setItems() async {
    return [];
  }

  Future<List<Item>> fetchItems() async {
    await Future.delayed(const Duration(seconds: 1));
    return SampleData.sampleItems;
  }

  Future<List<Item>> fetchTopics() async {
    await Future.delayed(const Duration(seconds: 1));
    return SampleData.sampleItems.where((i) => i.isTopic).toList();
  }
}
