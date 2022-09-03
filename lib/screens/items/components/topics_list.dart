import 'package:easynotes/cubits/cubit/topics_cubit.dart';
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
                itemBuilder: (context, idx) => Container(
                      padding:
                          const EdgeInsets.symmetric(vertical: ConstSpacing.sm),
                      child: Column(children: [
                        Icon(Icons.folder,
                            color: HexColor.fromHex(topics[idx].color)),
                        Text(topics[idx].title),
                      ]),
                    ));
        }
      },
    );
  }
}
