import 'package:easynotes/cubits/cubits.dart';
import 'package:easynotes/cubits/trash/trash_cubit.dart';
import 'package:easynotes/extensions/color_ext.dart';
import 'package:easynotes/screens/common/inline_button.dart';
import 'package:easynotes/screens/common/toolbar_button.dart';
import 'package:easynotes/screens/common/topic_dialog.dart';
import 'package:easynotes/screens/topic/topic_screen.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TopicsList extends StatelessWidget {
  const TopicsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          toolbarHeight: 40,
          backgroundColor: Colors.black12,
          elevation: 0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ToolbarButton(
                  iconData: FluentIcons.folder_add_20_filled,
                  title: 'Topic',
                  onPressed: () async {
                    ItemsCubit ic = BlocProvider.of<ItemsCubit>(context);
                    TopicCubit tc = BlocProvider.of<TopicCubit>(context);
                    await ic
                        .createItem(null, 0)
                        .then((cubit) => tc.select(cubit));
                    Dialog dlg = const TopicDialog(child: TopicScreen());
                    final created = await showDialog(
                        context: context, builder: (context) => dlg);
                    if (created != null && created == true) {
                      ic.insertTopicInTop(tc.topicCubit!);
                    }
                  }),
            ],
          )),
      body: BlocBuilder<ItemsCubit, ItemsState>(
          buildWhen: (prev, next) =>
              prev.status != next.status ||
              prev.differentialRebuildNoteToggle !=
                  next.differentialRebuildNoteToggle ||
              prev.selectedTopic != next.selectedTopic ||
              prev.topicCubits != next.topicCubits,
          builder: (context, state) {
            final topics = state.topicCubits;
            return SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ListView.builder(
                      shrinkWrap: true,
                      itemCount: topics.length,
                      itemBuilder: (context, idx) {
                        final topic = topics[idx];
                        final clr = HexColor.fromHex(topic.color);
                        return RootItemContainer(
                            key: UniqueKey(),
                            item: topic,
                            selectedTopic: state.selectedTopic,
                            color: clr);
                      }),
                  DragTarget<ItemCubit>(
                      onWillAccept: (itemCubit) =>
                          itemCubit != null && itemCubit.isTopic,
                      onAccept: (itemCubit) => itemCubit.changeParent(null),
                      builder: (context, __, ___) => Container()),
                  TrashContainer(key: UniqueKey())
                ],
              ),
            );
          }),
    );
  }
}

class TrashContainer extends StatelessWidget {
  const TrashContainer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<ItemCubit>(
        onWillAccept: (itemCubit) => itemCubit != null,
        onAccept: (itemCubit) {},
        builder: (context, __, ___) {
          ItemsCubit ic = context.read<ItemsCubit>();
          return Container(
            decoration: BoxDecoration(
                color: true ? Colors.white10 : Colors.transparent,
                border: true
                    ? const Border(
                        right: BorderSide(color: Colors.white70, width: 2))
                    : null),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              trailing: null,
              onTap: () => ic.selectTrashBin(),
              title: Stack(
                alignment: Alignment.center,
                children: [
                  Column(children: const [
                    Icon(FluentIcons.delete_24_filled, color: Colors.white70),
                    Text('Trash',
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            color: Colors.white70)),
                  ]),
                ],
              ),
            ),
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

class RootItemRow extends StatefulWidget {
  const RootItemRow(
      {super.key,
      required this.item,
      required this.selectedTopic,
      required this.color});

  final ItemCubit item;
  final ItemCubit? selectedTopic;
  final Color color;

  @override
  State<RootItemRow> createState() => _RootItemRowState();
}

class _RootItemRowState extends State<RootItemRow> {
  bool? hovering;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: (widget.selectedTopic != null &&
                  widget.item.id == widget.selectedTopic!.id)
              ? Colors.white10
              : Colors.transparent,
          border: (widget.selectedTopic != null &&
                  widget.item.id == widget.selectedTopic!.id)
              ? Border(right: BorderSide(color: widget.color, width: 2))
              : null),
      child: MouseRegion(
        onEnter: (PointerEvent e) => setState(() {
          hovering = true;
        }),
        onExit: (PointerEvent e) => setState(() {
          hovering = false;
        }),
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          trailing: null,
          onTap: () =>
              context.read<ItemsCubit>().selectTopicDirectly(widget.item),
          title: Stack(
            alignment: Alignment.center,
            children: [
              Column(children: [
                Icon(FluentIcons.folder_20_filled, color: widget.color),
                Text(widget.item.title,
                    style: TextStyle(
                        fontWeight: FontWeight.w400, color: widget.color)),
              ]),
              if (hovering == true)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InlineButton(
                      iconData: FluentIcons.edit_16_regular,
                      onPressed: () async {
                        ItemsCubit ic = BlocProvider.of<ItemsCubit>(context);
                        TopicCubit tc = BlocProvider.of<TopicCubit>(context);
                        tc.select(widget.item);
                        Dialog dlg = const TopicDialog(child: TopicScreen());
                        final changes = await showDialog(
                            context: context, builder: (context) => dlg);
                        if (changes == true) {
                          ic.handleItemsChanged();
                        }
                      },
                    ),
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }
}
