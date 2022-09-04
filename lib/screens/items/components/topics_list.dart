import 'package:easynotes/cubits/cubits.dart';
import 'package:easynotes/extensions/color_ext.dart';
import 'package:easynotes/models/sample_data.dart';
import 'package:easynotes/screens/common/uiconstants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TopicsList extends StatefulWidget {
  const TopicsList({Key? key}) : super(key: key);

  @override
  State<TopicsList> createState() => _TopicsListState();
}

class _TopicsListState extends State<TopicsList> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ItemsCubit, ItemsState>(
      buildWhen: (prev, next) =>
          prev.status != next.status ||
          prev.topic != next.topic ||
          prev.topics != next.topics,
      builder: (context, state) {
        print("building topics list");
        switch (state.status) {
          case ItemsStatus.error:
            return const Center(child: Text('Oops, something went wrong ...'));
          case ItemsStatus.loading:
            return const Center(child: CircularProgressIndicator());
          case ItemsStatus.success:
            final topics = state.topics;
            return BlocBuilder<ItemsCubit, ItemsState>(
              buildWhen: (prev, next) => prev.topic != next.topic,
              builder: (context, state) => ListView.builder(
                  itemCount: topics.length,
                  itemBuilder: (context, idx) {
                    if (state.topic != null) print(state.topic!.state.topic);
                    final clr =
                        HexColor.fromHex(topics[idx].state.topic!.color);
                    return Container(
                      decoration: BoxDecoration(
                          border: (state.topic != null &&
                                  topics[idx].state.topic!.id ==
                                      state.topic!.state.topic!.id)
                              ? Border(right: BorderSide(color: clr, width: 5))
                              : null),
                      child: ListTile(
                        onTap: () =>
                            context.read<ItemsCubit>().selectTopic(idx),
                        title: Column(children: [
                          Icon(Icons.folder, color: clr),
                          Text(topics[idx].state.topic!.title),
                        ]),
                      ),
                    );
                  }),
            );
        }
      },
    );
  }
}
