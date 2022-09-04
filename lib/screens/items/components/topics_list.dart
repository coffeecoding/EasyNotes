import 'package:easynotes/cubits/cubits.dart';
import 'package:easynotes/extensions/color_ext.dart';
import 'package:easynotes/models/sample_data.dart';
import 'package:easynotes/screens/common/uiconstants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TopicsList extends StatelessWidget {
  const TopicsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ItemsCubit, ItemsState>(
        buildWhen: (prev, next) =>
            prev.status != next.status ||
            prev.topic != next.topic ||
            prev.topics != next.topics,
        builder: (context, state) {
          final topics = state.topics;
          return ListView.builder(
              itemCount: topics.length,
              itemBuilder: (context, idx) {
                final clr = HexColor.fromHex(topics[idx].state.topic!.color);
                return Container(
                  decoration: BoxDecoration(
                      border: (state.topic != null &&
                              topics[idx].state.topic!.id ==
                                  state.topic!.state.topic!.id)
                          ? Border(right: BorderSide(color: clr, width: 5))
                          : null),
                  child: ListTile(
                    onTap: () => context.read<ItemsCubit>().selectTopic(idx),
                    title: Column(children: [
                      Icon(Icons.folder, color: clr),
                      Text(topics[idx].state.topic!.title),
                    ]),
                  ),
                );
              });
        });
  }
}
