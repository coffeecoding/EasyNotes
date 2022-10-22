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
          return Column(
            children: [
              ListView.builder(
                  shrinkWrap: true,
                  itemCount: topics.length,
                  itemBuilder: (context, idx) {
                    final clr = HexColor.fromHex(topics[idx].color);
                    return DragTarget<ItemCubit>(
                      onWillAccept: (itemCubit) =>
                          itemCubit != null && itemCubit.parent != topics[idx],
                      onAccept: (itemCubit) =>
                          itemCubit.changeParent(topics[idx]),
                      builder: (context, __, ___) => Draggable(
                        data: topics[idx],
                        feedback: Material(
                          child: Container(
                            color: Colors.black26,
                            width: 100,
                            height: 50,
                            child: RootItemContainer(
                                selectedTopic: state.selectedTopic,
                                item: topics[idx],
                                color: clr),
                          ),
                        ),
                        child: RootItemContainer(
                            selectedTopic: state.selectedTopic,
                            item: topics[idx],
                            color: clr),
                      ),
                    );
                  }),
              Expanded(
                  child: DragTarget<ItemCubit>(
                      onWillAccept: (itemCubit) =>
                          itemCubit != null && itemCubit.isTopic,
                      onAccept: (itemCubit) => itemCubit.changeParent(null),
                      builder: (context, __, ___) => Container())),
            ],
          );
        });
  }
}

class RootItemContainer extends StatelessWidget {
  const RootItemContainer(
      {super.key,
      required this.item,
      required this.selectedTopic,
      required this.color});

  final ItemCubit item;
  final ItemCubit? selectedTopic;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: (selectedTopic != null && item.id == selectedTopic!.id)
              ? Colors.black12
              : Colors.transparent,
          border: (selectedTopic != null && item.id == selectedTopic!.id)
              ? Border(right: BorderSide(color: color, width: 5))
              : null),
      child: ListTile(
        onTap: () => context.read<ItemsCubit>().selectTopicDirectly(item),
        title: Column(children: [
          Icon(Icons.folder, color: color),
          Text(item.title, style: const TextStyle(fontWeight: FontWeight.w100)),
        ]),
      ),
    );
  }
}
