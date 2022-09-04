import 'package:easynotes/models/item.dart';
import 'package:easynotes/models/sample_data.dart';

class ItemRepository {
  Future<List<Item>> fetchItems() async {
    await Future.delayed(const Duration(seconds: 1));
    return SampleData.sampleItems;
  }

  Future<List<Item>> fetchTopics() async {
    await Future.delayed(const Duration(seconds: 1));
    return SampleData.sampleItems.where((i) => i.isTopic).toList();
  }
}
