import 'package:easynotes/cubits/cubits.dart';
import 'package:easynotes/cubits/item_vm/item_vm.dart';
import 'package:easynotes/extensions/color_ext.dart';
import 'package:easynotes/screens/common/toolbar_button.dart';
import 'package:easynotes/screens/items/components/widgets/list_item.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChildrenList extends StatelessWidget {
  const ChildrenList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChildrenItemsCubit, ChildrenItemsState>(
        builder: (context, state) {
      final selectedItem = context.read<RootItemsCubit>().selectedItem;
      //if (state.status == ChildrenItemsStatus.unselected) {
      if (selectedItem == null) {
        return const Center(child: Text('No Topic selected'));
      }
      final childrenItemsCubit = context.read<ChildrenItemsCubit>();
      final itemCubits = state.childrenCubits;
      final clr = HexColor.fromHex(selectedItem.color);
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
                          childrenItemsCubit.createSubTopic(selectedItem)),
                  ToolbarButton(
                      iconData: FluentIcons.note_add_20_regular,
                      title: 'Note',
                      onPressed: () async {
                        final snc = context.read<SelectedNoteCubit>();
                        ItemVM i =
                            await childrenItemsCubit.createNote(selectedItem);
                        snc.handleNoteChanged(i);
                      }),
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
      onAccept: (incomingItem) async {
        final ric = context.read<RootItemsCubit>();
        final cic = context.read<ChildrenItemsCubit>();
        await incomingItem.changeParent(newParent: item, ric: ric, cic: cic);
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
                    final cic = context.read<ChildrenItemsCubit>();
                    cic.handleItemsChanging();
                    item.parent!.discardSubtopicChanges(item);
                    cic.handleItemsChanged();
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
