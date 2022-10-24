import 'dart:ui';

import 'package:easynotes/cubits/cubits.dart';
import 'package:easynotes/extensions/color_ext.dart';
import 'package:easynotes/screens/common/inline_button.dart';
import 'package:easynotes/screens/common/toolbar_button.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChildrenList extends StatelessWidget {
  const ChildrenList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ItemsCubit, ItemsState>(
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
          return Scaffold(
              appBar: AppBar(
                  titleSpacing: 8,
                  toolbarHeight: 40,
                  backgroundColor: Colors.black12,
                  elevation: 0,
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ToolbarButton(
                          iconData: FluentIcons.folder_add_20_regular,
                          title: 'Subtopic',
                          onPressed: () => BlocProvider.of<ItemsCubit>(context)
                              .createSubTopic(null)),
                      ToolbarButton(
                          iconData: FluentIcons.note_add_20_regular,
                          title: 'Note',
                          onPressed: () => BlocProvider.of<ItemsCubit>(context)
                              .createNote(null)),
                    ],
                  )),
              body: Container(
                alignment: Alignment.topLeft,
                child: ListView.builder(
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    itemCount: itemCubits.length,
                    itemBuilder: (context, i) {
                      final item = itemCubits[i];
                      return ExpandableItemContainer(color: clr, item: item);
                    }),
              ));
        });
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
    final itemContainerView = DragDropContainer(item: item, color: color);
    return item.isTopic && item.expanded
        ? Column(children: [
            itemContainerView,
            item.children.isEmpty
                ? Container(
                    padding: EdgeInsets.only(
                        left: (item.getAncestorCount() - 1) * 28),
                    height: 20,
                    child: Center(
                        child: Text('This topic is empty',
                            style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Theme.of(context).hintColor))),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: item.children.length,
                    itemBuilder: (context, j) {
                      return item.children[j].isTopic &&
                              item.children[j].expanded
                          ? ExpandableItemContainer(
                              item: item.children[j], color: color)
                          : DragDropContainer(
                              color: color, item: item.children[j]);
                    })
          ])
        : itemContainerView;
  }
}

class DragDropContainer extends StatelessWidget {
  const DragDropContainer({super.key, required this.item, required this.color});

  final ItemCubit item;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DragTarget<ItemCubit>(
      onWillAccept: (itemCubit) {
        return item.isTopic &&
            itemCubit != null &&
            itemCubit.parent != item &&
            itemCubit != item;
      },
      onAccept: (itemCubit) => itemCubit.changeParent(item),
      builder: (context, __, ___) => Draggable(
          data: item,
          feedback: Material(
            child: Container(
              color: Colors.transparent,
              width: 300,
              height: 50,
              child: ItemRow(color: color, item: item),
            ),
          ),
          child: item.isTopic &&
                  (item.status == ItemStatus.draft ||
                      item.status == ItemStatus.newDraft)
              ? EditableItemContainer(
                  color: color,
                  item: item,
                  onDiscard: () => item.parent!.removeChild(item),
                )
              : ItemContainer(
                  color: color,
                  item: item,
                  onTap: () => context.read<ItemsCubit>().selectChild(item))),
    );
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
            padding: EdgeInsets.only(left: (item.getAncestorCount() - 1) * 28),
            // move the box decoration back to this level if we want
            child: Container(
                decoration: BoxDecoration(
                  color:
                      (state.selectedNote != null && item == state.selectedNote)
                          ? Theme.of(context).cardColor
                          : Colors.transparent,
                ),
                child: ItemRow(item: item, color: color, onTap: onTap)));
      },
    );
  }
}

/// Used for newly created subtopics that are editable in line
class EditableItemContainer extends StatelessWidget {
  const EditableItemContainer({
    super.key,
    required this.item,
    required this.color,
    this.onDiscard,
  });

  final ItemCubit item;
  final Color color;
  final Function()? onDiscard;

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
            child: EditableItemRow(
                item: item, color: color, onDiscard: onDiscard));
      },
    );
  }
}

class EditableItemRow extends StatelessWidget {
  EditableItemRow(
      {super.key, required this.item, required this.color, this.onDiscard})
      : titleCtr = TextEditingController(text: item.titleField);

  final ItemCubit item;
  final Color color;
  final Function()? onDiscard;
  final TextEditingController titleCtr;

  bool? isSaving;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {},
      leading: Icon(
          item.item_type == 0
              ? FluentIcons.folder_20_filled
              : FluentIcons.note_20_regular,
          color: color),
      horizontalTitleGap: 0,
      title: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (v) => item.saveLocalState(titleField: v),
              selectionHeightStyle: BoxHeightStyle.tight,
              controller: titleCtr,
              style: TextStyle(
                  fontWeight: item.status == ItemStatus.draft
                      ? FontWeight.w700
                      : FontWeight.w100),
              maxLines: 1, // remove this to line-break instead
            ),
          ),
          InlineButton(
              iconData: FluentIcons.dismiss_12_regular,
              enabledColor: Colors.white70,
              onPressed: onDiscard),
          StatefulBuilder(builder: ((context, setState) {
            return isSaving == true
                ? const Center(child: CircularProgressIndicator())
                : InlineButton(
                    iconData: FluentIcons.save_16_regular,
                    enabledColor: Colors.white70,
                    onPressed: () async {
                      setState(() => isSaving = true);
                      await item.save(titleField: titleCtr.text);
                      item.itemsCubit.handleItemsChanged();
                      setState(() => isSaving = false);
                    });
          })),
        ],
      ),
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
