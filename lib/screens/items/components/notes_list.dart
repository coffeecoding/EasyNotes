import 'package:easynotes/cubits/cubits.dart';
import 'package:easynotes/extensions/color_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotesList extends StatelessWidget {
  const NotesList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ItemsCubit, ItemsState>(
        // potentially add condition to rebuild when changing a node's parent
        // or even a single, not selected item changes (e.g. it's title)
        buildWhen: (prev, next) =>
            prev.selectedNote != next.selectedNote ||
            prev.selectedTopic != next.selectedTopic ||
            prev.didChildExpansionToggle != next.didChildExpansionToggle,
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
                  return ExpandableItemContainer(
                      color: clr, item: item, selectedNote: state.selectedNote);
                }),
          );
        });
  }
}

class ExpandableItemContainer extends StatelessWidget {
  const ExpandableItemContainer({
    super.key,
    required this.item,
    this.selectedNote,
    required this.color,
  });

  final ItemCubit item;
  final ItemCubit? selectedNote;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final itemContainerView = ItemContainer(
        color: color,
        item: item,
        selectedNote: selectedNote,
        onTap: () => context.read<ItemsCubit>().selectChild(item));
    return item.isTopic && item.expanded
        ? Column(children: [
            itemContainerView,
            ListView.builder(
                shrinkWrap: true,
                itemCount: item.children.length,
                itemBuilder: (context, j) {
                  return item.children[j].isTopic && item.children[j].expanded
                      ? ExpandableItemContainer(
                          item: item.children[j],
                          color: color,
                          selectedNote: selectedNote)
                      : ItemContainer(
                          color: color,
                          item: item.children[j],
                          selectedNote: selectedNote,
                          onTap: () => context
                              .read<ItemsCubit>()
                              .selectChild(item.children[j]));
                })
          ])
        : itemContainerView;
  }
}

class ItemContainer extends StatelessWidget {
  const ItemContainer({
    super.key,
    required this.item,
    this.selectedNote,
    required this.color,
    this.onTap,
  });

  final ItemCubit item;
  final ItemCubit? selectedNote;
  final Color color;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(left: (item.getAncestorCount() - 1) * 20),
        decoration: BoxDecoration(
          color: (selectedNote != null && item.id == selectedNote!.id)
              ? Theme.of(context).cardColor
              : Colors.transparent,
          border: Border(
              bottom: BorderSide(color: Theme.of(context).cardColor, width: 1)),
        ),
        child: ItemRow(item: item, color: color, onTap: onTap));
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
      leading: Icon(item.item_type == 0 ? Icons.folder : Icons.note_outlined,
          color: color),
      horizontalTitleGap: 0,
      title: Text(
        item.title,
        overflow: TextOverflow.ellipsis, // remove this to line-break instead
        softWrap: false,
        maxLines: 1, // remove this to line-break instead
      ),
    );
  }
}
