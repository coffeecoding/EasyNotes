import 'package:easynotes/cubits/cubits.dart';
import 'package:easynotes/extensions/color_ext.dart';
import 'package:easynotes/screens/common/responsive.dart';
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
                    final topic = topics[idx];
                    final clr = HexColor.fromHex(topic.color);
                    final dragHandle = Container(
                        child: Responsive.isDesktop(context)
                            ? ReorderableDragStartListener(
                                index: idx,
                                child: const Icon(Icons.drag_handle))
                            : ReorderableDelayedDragStartListener(
                                index: idx,
                                child: const Icon(Icons.drag_handle)));
                    return RootItemContainer(
                        key: UniqueKey(),
                        item: topic,
                        selectedTopic: state.selectedTopic,
                        color: clr);
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
  const RootItemContainer({
    super.key,
    required this.item,
    required this.selectedTopic,
    required this.color,
  });

  final ItemCubit item;
  final ItemCubit? selectedTopic;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DragTarget<ItemCubit>(
      onWillAccept: (itemCubit) =>
          itemCubit != null && itemCubit.parent != item && itemCubit != item,
      onAccept: (itemCubit) => itemCubit.changeParent(item),
      builder: (context, __, ___) => Draggable(
        data: item,
        feedback: Material(
          child: Container(
            color: Colors.black26,
            width: 100,
            height: 50,
            child: RootItemRow(
                selectedTopic: selectedTopic, item: item, color: color),
          ),
        ),
        child:
            RootItemRow(selectedTopic: selectedTopic, item: item, color: color),
      ),
    );
  }
}

class RootItemRow extends StatelessWidget {
  const RootItemRow(
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
