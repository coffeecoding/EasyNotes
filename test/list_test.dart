import 'package:easynotes/config/sample_data.dart';
import 'package:easynotes/models/item.dart';

void main() {
  List<Item> items = SampleData.sampleItems;

  items.forEach((i) => print('${i.id}, ${i.title}, ${i.trashed}'));
}
