import 'package:easynotes/cubits/cubits.dart';
import 'package:easynotes/extensions/color_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TopicsList extends StatelessWidget {
  const TopicsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ItemsCubit, ItemsState>(
        buildWhen: (prev, next) =>
            prev.status != next.status ||
            prev.selectedTopic != next.selectedTopic ||
            prev.topicCubits != next.topicCubits,
        builder: (context, state) {
          final topics = state.topicCubits;
          return ListView.builder(
              itemCount: topics.length,
              itemBuilder: (context, idx) {
                final clr = HexColor.fromHex(topics[idx].color);
                return Container(
                  decoration: BoxDecoration(
                      border: (state.selectedTopic != null &&
                              topics[idx].id == state.selectedTopic!.id)
                          ? Border(right: BorderSide(color: clr, width: 5))
                          : null),
                  child: ListTile(
                    onTap: () => context.read<ItemsCubit>().selectTopic(idx),
                    title: Column(children: [
                      Icon(Icons.folder, color: clr),
                      Text(topics[idx].title),
                    ]),
                  ),
                );
              });
        });
  }
}
