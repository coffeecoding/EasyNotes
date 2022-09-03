import 'package:easynotes/extensions/color_ext.dart';
import 'package:easynotes/models/sample_data.dart';
import 'package:easynotes/screens/common/uiconstants.dart';
import 'package:flutter/material.dart';

class TopicsList extends StatelessWidget {
  const TopicsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final topics = SampleData.sampleItems
        .where((i) => i.parent_id == null || i.parent_id!.isEmpty)
        .toList();
    return ListView.builder(
        itemCount: topics.length,
        itemBuilder: (context, idx) => Container(
              padding: const EdgeInsets.symmetric(vertical: ConstSpacing.sm),
              child: Column(children: [
                Icon(Icons.folder, color: HexColor.fromHex(topics[idx].color)),
                Text(topics[idx].title),
              ]),
            ));
  }
}
