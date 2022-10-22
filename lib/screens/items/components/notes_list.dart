import 'package:easynotes/cubits/cubits.dart';
import 'package:easynotes/extensions/color_ext.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotesList extends StatelessWidget {
  const NotesList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          titleSpacing: 8,
          toolbarHeight: 40,
          backgroundColor: Colors.black12,
          elevation: 0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextButton(
                child: Row(children: const [
                  Icon(FluentIcons.folder_add_20_regular,
                      color: Colors.white70),
                  SizedBox(width: 4),
                  Text('Subtopic',
                      style: TextStyle(
                          fontWeight: FontWeight.w400, color: Colors.white70)),
                ]),
                onPressed: () {},
              ),
              TextButton(
                child: Row(children: const [
                  Icon(FluentIcons.note_add_20_regular, color: Colors.white70),
                  SizedBox(width: 4),
                  Text('Note',
                      style: TextStyle(
                          fontWeight: FontWeight.w400, color: Colors.white70)),
                ]),
                onPressed: () {},
              ),
            ],
          )),
      body: BlocBuilder<ItemsCubit, ItemsState>(
          buildWhen: (prev, next) =>
              prev.selectedNote != next.selectedNote ||
              prev.selectedTopic != next.selectedTopic ||
              prev.didChildExpansionToggle != next.didChildExpansionToggle ||
              prev.differentialRebuildNoteToggle !=
                  next.differentialRebuildNoteToggle ||
              prev.selectedTopic?.children.length !=
                  next.selectedTopic?.children.length,
          builder: (context, state) {
            final selectedTopic = state.selectedTopic;
            if (selectedTopic == null) {
              return const Center(child: Text('No Topic selected'));
            }
            final itemCubits = selectedTopic.children;
            final clr = HexColor.fromHex(selectedTopic.color);
            return Container(
              alignment: Alignment.topLeft,
              child: ListView.builder(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  itemCount: itemCubits.length,
                  itemBuilder: (context, i) {
                    final item = itemCubits[i];
                    return ExpandableItemContainer(color: clr, item: item);
                  }),
            );
          }),
    );
  }
}

class ExpandableItemContainer extends StatelessWidget {
  const ExpandableItemContainer({
    super.key,
    required this.item,
    required this.color,
  });

  final ItemCubit item;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final itemContainerView = Draggable(
        data: item,
        feedback: Material(
          child: Container(
            color: Colors.transparent,
            width: 300,
            height: 50,
            child: ItemRow(color: color, item: item),
          ),
        ),
        child: ItemContainer(
            color: color,
            item: item,
            onTap: () => context.read<ItemsCubit>().selectChild(item)));
    return item.isTopic && item.expanded
        ? Column(children: [
            itemContainerView,
            ListView.builder(
                shrinkWrap: true,
                itemCount: item.children.length,
                itemBuilder: (context, j) {
                  return item.children[j].isTopic && item.children[j].expanded
                      ? ExpandableItemContainer(
                          item: item.children[j], color: color)
                      : Draggable(
                          data: item.children[j],
                          feedback: Material(
                            child: Container(
                              color: Colors.transparent,
                              width: 300,
                              height: 50,
                              child:
                                  ItemRow(color: color, item: item.children[j]),
                            ),
                          ),
                          child: ItemContainer(
                              color: color,
                              item: item.children[j],
                              onTap: () => context
                                  .read<ItemsCubit>()
                                  .selectChild(item.children[j])));
                })
          ])
        : itemContainerView;
  }
}

class ItemContainer extends StatelessWidget {
  const ItemContainer({
    super.key,
    required this.item,
    required this.color,
    this.onTap,
  });

  final ItemCubit item;
  final Color color;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SelectedNoteCubit, SelectedNoteState>(
      builder: (context, state) {
        return Container(
            padding: EdgeInsets.only(left: (item.getAncestorCount() - 1) * 20),
            decoration: BoxDecoration(
              color: (state.selectedNote != null &&
                      item.id == state.selectedNote!.id)
                  ? Theme.of(context).cardColor
                  : Colors.transparent,
              border: Border(
                  bottom:
                      BorderSide(color: Theme.of(context).cardColor, width: 1)),
            ),
            child: ItemRow(item: item, color: color, onTap: onTap));
      },
    );
  }
}

class ItemRow extends StatelessWidget {
  const ItemRow(
      {super.key, required this.item, required this.color, this.onTap});

  final ItemCubit item;
  final Color color;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(
          item.item_type == 0
              ? FluentIcons.folder_20_filled
              : FluentIcons.note_20_regular,
          color: color),
      horizontalTitleGap: 0,
      title: Text(
        item.title,
        style: TextStyle(
            fontWeight: item.status == ItemStatus.draft
                ? FontWeight.w700
                : FontWeight.w100),
        overflow: TextOverflow.ellipsis, // remove this to line-break instead
        softWrap: false,
        maxLines: 1, // remove this to line-break instead
      ),
    );
  }
}
