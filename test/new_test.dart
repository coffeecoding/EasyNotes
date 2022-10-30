import 'package:easynotes/config/sample_data.dart';
import 'package:easynotes/models/item.dart';

void main() {
  List<Item> items = SampleData.sampleItems;

  items.forEach((i) => print('${i.id}, ${i.title}, ${i.trashed}'));

  Iterable<int> subset = items
      .where((i) => i.title.contains('Topic'))
      .map((i) => items.indexOf(i));

  print('----------- REPLACING ----------');

  subset.forEach((i) =>
      items[i] = items[i].copyWith(title: 'XXXXX', trashed: items[i].trashed));

  items.forEach((i) => print('${i.id}, ${i.title}, ${i.trashed}'));
}
