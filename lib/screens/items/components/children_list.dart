import 'dart:ui';

import 'package:easynotes/cubits/cubits.dart';
import 'package:easynotes/cubits/item_vm/item_vm.dart';
import 'package:easynotes/extensions/color_ext.dart';
import 'package:easynotes/screens/common/inline_button.dart';
import 'package:easynotes/screens/common/progress_indicators.dart';
import 'package:easynotes/screens/common/toolbar_button.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChildrenList extends StatelessWidget {
  const ChildrenList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChildrenItemsCubit, ChildrenItemsState>(
        builder: (context, state) {
      final selectedTopic = context.read<RootItemsCubit>().selectedTopic;
      //if (state.status == ChildrenItemsStatus.unselected) {
      if (selectedTopic == null) {
        return const Center(child: Text('No Topic selected'));
      }
      final childrenItemsCubit = context.read<ChildrenItemsCubit>();
      final itemCubits = state.childrenCubits;
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
                      onPressed: () =>
                          childrenItemsCubit.createSubTopic(selectedTopic)),
                  ToolbarButton(
                      iconData: FluentIcons.note_add_20_regular,
                      title: 'Note',
                      onPressed: () =>
                          childrenItemsCubit.createNote(selectedTopic)),
                ],
              )),
          body: Container(
            alignment: Alignment.topLeft,
            child: Stack(
              children: [
                ListView.builder(
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    itemCount: itemCubits.length,
                    itemBuilder: (context, i) {
                      final item = itemCubits[i];
                      return ExpandableItemContainer(color: clr, item: item);
                    }),
                state.status == ChildrenItemsStatus.busy
                    ? Positioned.fill(
                        child: Container(
                            color: Colors.black26,
                            child: const Center(
                                child: CircularProgressIndicator())))
                    : Container(),
              ],
            ),
          ));
    });
  }
}

class ExpandableItemContainer extends StatefulWidget {
  const ExpandableItemContainer({
    super.key,
    required this.item,
    required this.color,
  });

  final ItemVM item;
  final Color color;

  @override
  State<ExpandableItemContainer> createState() =>
      _ExpandableItemContainerState();
}

class _ExpandableItemContainerState extends State<ExpandableItemContainer> {
  @override
  Widget build(BuildContext context) {
    final itemContainerView = DragDropContainer(
      item: widget.item,
      color: widget.color,
      onTap: () {
        if (widget.item.isTopic) {
          widget.item.expanded = !widget.item.expanded;
          setState(() {});
        } else {
          context
              .read<ChildrenItemsCubit>()
              .handleSelectionChanged(widget.item);
          context.read<SelectedNoteCubit>().handleNoteChanged(widget.item);
        }
      },
    );
    return widget.item.isTopic && widget.item.expanded
        ? Column(children: [
            itemContainerView,
            widget.item.children.isEmpty
                ? Container(
                    padding: EdgeInsets.only(
                        left: (widget.item.getAncestorCount() - 1) * 28),
                    height: 20,
                    child: Center(
                        child: Text('This topic is empty',
                            style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Theme.of(context).hintColor))),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: widget.item.children.length,
                    itemBuilder: (context, j) {
                      return widget.item.children[j].isTopic &&
                              widget.item.children[j].expanded
                          ? ExpandableItemContainer(
                              item: widget.item.children[j],
                              color: widget.color)
                          : DragDropContainer(
                              onTap: () {
                                if (widget.item.children[j].isTopic) {
                                  widget.item.children[j].expanded =
                                      !widget.item.children[j].expanded;
                                  setState(() {});
                                } else {
                                  context
                                      .read<ChildrenItemsCubit>()
                                      .handleSelectionChanged(
                                          widget.item.children[j]);
                                  context
                                      .read<SelectedNoteCubit>()
                                      .handleNoteChanged(
                                          widget.item.children[j]);
                                }
                              },
                              color: widget.color,
                              item: widget.item.children[j]);
                    })
          ])
        : itemContainerView;
  }
}

class DragDropContainer extends StatelessWidget {
  const DragDropContainer(
      {super.key, required this.item, required this.color, this.onTap});

  final ItemVM item;
  final Color color;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return DragTarget<ItemVM>(
      onWillAccept: (itemCubit) {
        return item.isTopic &&
            itemCubit != null &&
            itemCubit.parent != item &&
            itemCubit != item;
      },
      onAccept: (itemCubit) async {
        final ric = context.read<RootItemsCubit>();
        item.parentListCubit.handleItemsChanging();
        if (item.parent == null) {
          ric.handleItemsChanging();
        }
        await itemCubit.changeParent(item);
        item.parentListCubit.handleItemsChanged();
        if (item.parent == null) {
          ric.handleItemsChanged();
        }
      },
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
                  (item.status == ItemVMStatus.draft ||
                      item.status == ItemVMStatus.newDraft)
              ? EditableItemContainer(
                  color: color,
                  item: item,
                  onDiscard: () {
                    item.parentListCubit.handleItemsChanging();
                    item.parent!.discardSubtopicChanges(item);
                    item.parentListCubit.handleItemsChanged();
                  })
              : ItemContainer(color: color, item: item, onTap: onTap)),
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

  final ItemVM item;
  final Color color;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SelectedNoteCubit, SelectedNoteState>(
      buildWhen: (p, n) => p != n,
      builder: (context, state) {
        return Container(
            padding: EdgeInsets.only(left: (item.getAncestorCount() - 1) * 28),
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

  final ItemVM item;
  final Color color;
  final Function()? onDiscard;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SelectedNoteCubit, SelectedNoteState>(
      builder: (context, state) {
        return Container(
            padding: EdgeInsets.only(left: (item.getAncestorCount() - 1) * 28),
            decoration: BoxDecoration(
              color: (state.selectedNote != null && item == state.selectedNote)
                  ? Theme.of(context).cardColor
                  : Colors.transparent,
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

  final ItemVM item;
  final Color color;
  final Function()? onDiscard;
  final TextEditingController titleCtr;

  bool? isSaving;

  @override
  Widget build(BuildContext context) {
    FocusNode titleFN = FocusNode();
    titleFN.requestFocus();
    return ListTile(
      onTap: () {},
      contentPadding: const EdgeInsets.only(left: 16, right: 4),
      leading: Icon(
          item.item_type == 0
              ? FluentIcons.folder_20_filled
              : FluentIcons.note_20_regular,
          color: color),
      horizontalTitleGap: 0,
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: TextField(
              decoration: null,
              focusNode: titleFN,
              onChanged: (v) => item.saveLocalState(titleField: v),
              selectionHeightStyle: BoxHeightStyle.tight,
              controller: titleCtr,
              style: const TextStyle(fontWeight: FontWeight.w100),
              maxLines: 1, // remove this to line-break instead
            ),
          ),
          InlineButton(
              iconData: FluentIcons.dismiss_12_regular, onPressed: onDiscard),
          StatefulBuilder(builder: ((context, setState) {
            return isSaving == true
                ? const Center(child: InlineCircularProgressIndicator())
                : InlineButton(
                    iconData: FluentIcons.save_16_regular,
                    onPressed: () async {
                      setState(() => isSaving = true);
                      item.parentListCubit.handleItemsChanging();
                      await item.save(titleField: titleCtr.text);
                      item.parentListCubit.handleItemsChanged();
                      setState(() => isSaving = false);
                    });
          })),
        ],
      ),
    );
  }
}

class ItemRow extends StatefulWidget {
  const ItemRow(
      {super.key, required this.item, required this.color, this.onTap});

  final ItemVM item;
  final Color color;
  final Function()? onTap;

  @override
  State<ItemRow> createState() => _ItemRowState();
}

class _ItemRowState extends State<ItemRow> {
  bool? hovering;
  bool? isSaving;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (PointerEvent e) => setState(() {
        hovering = true;
      }),
      onExit: (PointerEvent e) => setState(() {
        hovering = false;
      }),
      child: ListTile(
        contentPadding: const EdgeInsets.only(left: 16, right: 4),
        onTap: widget.onTap,
        leading: Icon(
            widget.item.item_type == 0
                ? FluentIcons.folder_20_filled
                : FluentIcons.note_20_regular,
            color: widget.color),
        horizontalTitleGap: 0,
        title: Row(
          children: [
            Expanded(
              child: Text(
                widget.item.title,
                style: TextStyle(
                    fontWeight: widget.item.status == ItemVMStatus.draft &&
                            !widget.item.isTopic
                        ? FontWeight.w700
                        : FontWeight.w100),
                overflow:
                    TextOverflow.ellipsis, // remove this to line-break instead
                softWrap: false,
                maxLines: 1, // remove this to line-break instead
              ),
            ),
            if (hovering == true && widget.item.isTopic)
              SizedBox(
                  width: 32,
                  child: PopupMenuButton(
                      splashRadius: 1,
                      elevation: 1,
                      padding: EdgeInsets.zero,
                      icon: const Icon(FluentIcons.more_vertical_16_regular),
                      itemBuilder: (context) {
                        final cib =
                            BlocProvider.of<ChildrenItemsCubit>(context);
                        return <PopupMenuItem<InlineButton>>[
                          PopupMenuItem<InlineButton>(
                              onTap: () {
                                widget.item.parentListCubit
                                    .handleItemsChanging();
                                widget.item.saveLocalState(
                                    newStatus: ItemVMStatus.draft);
                                widget.item.parentListCubit
                                    .handleItemsChanged();
                              },
                              padding: const EdgeInsets.only(left: 8),
                              key: UniqueKey(),
                              child: InlineButton(
                                  title: 'Edit',
                                  iconData: FluentIcons.edit_16_regular,
                                  onPressed: () {})),
                          PopupMenuItem<InlineButton>(
                              onTap: () => cib.createSubTopic(widget.item),
                              padding: const EdgeInsets.only(left: 8),
                              key: UniqueKey(),
                              child: InlineButton(
                                  title: 'Add Subtopic',
                                  iconData: FluentIcons.folder_add_20_regular,
                                  onPressed: () {})),
                          PopupMenuItem<InlineButton>(
                              onTap: () => cib.createNote(widget.item),
                              padding: const EdgeInsets.only(left: 8),
                              key: UniqueKey(),
                              child: InlineButton(
                                  title: 'Add Note',
                                  iconData: FluentIcons.note_add_20_regular,
                                  onPressed: () {})),
                        ];
                      })),
            if ((hovering == true || widget.item.pinned) && isSaving != true)
              InlineButton(
                iconData: FluentIcons.pin_16_regular,
                onPressed: () async {
                  setState(() {
                    isSaving = true;
                  });
                  await widget.item.togglePinned();
                  setState(() {
                    isSaving = false;
                  });
                },
              ),
            if (isSaving == true) const InlineCircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
