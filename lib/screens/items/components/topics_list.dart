import 'package:easynotes/cubits/cubit/topics_cubit.dart';
import 'package:easynotes/cubits/selected_topic/selected_topic_cubit.dart';
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
    return BlocBuilder<TopicsCubit, TopicsState>(
      buildWhen: (prev, next) => prev.status != next.status,
      builder: (context, state) {
        switch (state.status) {
          case TopicsStatus.failure:
            return const Center(child: Text('Oops, something went wrong ...'));
          case TopicsStatus.loading:
            return const Center(child: CircularProgressIndicator());
          case TopicsStatus.success:
            final topics = context.read<TopicsCubit>().state.topics;
            return ListView.builder(
                itemCount: topics.length,
                itemBuilder: (context, idx) =>
                    BlocBuilder<SelectedTopicCubit, SelectedTopicState>(
                        builder: (context, state) {
                      final clr = HexColor.fromHex(topics[idx].color);
                      return Container(
                        decoration: BoxDecoration(
                            border: (state.topic != null &&
                                    topics[idx] == state.topic)
                                ? Border(
                                    right: BorderSide(color: clr, width: 5))
                                : null),
                        child: ListTile(
                          onTap: () => context
                              .read<SelectedTopicCubit>()
                              .select(topics[idx]),
                          title: Column(children: [
                            Icon(Icons.folder, color: clr),
                            Text(topics[idx].title),
                          ]),
                        ),
                      );
                    }));
        }
      },
    );
  }
}
