import 'package:easynotes/cubits/cubits.dart';
import 'package:easynotes/cubits/item_vm/item_vm.dart';
import 'package:easynotes/cubits/trashed_items/trashed_items_cubit.dart';
import 'package:easynotes/screens/common/inline_button.dart';
import 'package:easynotes/screens/common/progress_indicators.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TrashList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TrashedItemsCubit, TrashedItemsState>(
        builder: (context, state) {
      final itemCubits = state.items;
      return itemCubits.isEmpty
          ? const Center(child: Text('Empty'))
          : Container(
              alignment: Alignment.topLeft,
              child: Stack(
                children: [
                  ListView.builder(
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      itemCount: itemCubits.length,
                      itemBuilder: (context, i) {
                        final item = itemCubits[i];
                        final clr = item.getRootAncestor()?.color ?? item.color;
                        return ExpandableItemContainer(
                            color: Color(int.parse(clr, radix: 16)),
                            item: item);
                      }),
                  state.status == TrashedItemsStatus.busy
                      ? Positioned.fill(
                          child: Container(
                              color: Colors.black26,
                              child: const Center(
                                  child: CircularProgressIndicator())))
                      : Container(),
                ],
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
        }
      },
    );
    return widget.item.isTopic && widget.item.expanded
        ? Column(children: [
            itemContainerView,
            widget.item.children.isEmpty
                ? Container(
                    padding: EdgeInsets.only(
                        left: widget.item.getTrashedAncestorCount() * 28),
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
        final tic = context.read<TrashedItemsCubit>();
        await incomingItem.changeParent(newParent: item, ric: ric, cic: tic);
        tic.removeItem(incomingItem);
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
          child: ItemContainer(color: color, item: item, onTap: onTap)),
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
            padding: item.parent?.trashed == null
                ? EdgeInsets.zero
                : EdgeInsets.only(left: item.getTrashedAncestorCount() * 28),
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
  bool? isDeleteing;

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
            if (widget.item.status == ItemVMStatus.draft ||
                widget.item.status == ItemVMStatus.newDraft)
              const Icon(
                FluentIcons.circle_small_20_filled,
                color: Colors.white,
              ),
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
            if (hovering == true || isDeleteing == true)
              StatefulBuilder(builder: (context, setState) {
                return isDeleteing == true
                    ? const Center(
                        child: InlineCircularProgressIndicator(
                        color: Colors.red,
                      ))
                    : InlineButton(
                        iconData: FluentIcons.dismiss_16_regular,
                        onPressed: () async {
                          setState(() {
                            isDeleteing = true;
                          });
                          final snc = context.read<SelectedNoteCubit>();
                          final tic = context.read<TrashedItemsCubit>();
                          tic.handleItemsChanging();
                          await widget.item.delete();
                          if (snc.note == widget.item) {
                            snc.handleNoteChanged(null);
                          }
                          widget.item.parent?.removeChild(widget.item);
                          tic.removeItem(widget.item);
                          tic.handleItemsChanged();
                          setState(() {
                            isDeleteing = false;
                          });
                        },
                      );
              }),
          ],
        ),
      ),
    );
  }
}
