import 'dart:ui';

import 'package:easynotes/cubits/cubits.dart';
import 'package:easynotes/cubits/item_vm/item_vm.dart';
import 'package:easynotes/screens/common/inline_button.dart';
import 'package:easynotes/screens/common/progress_indicators.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
                      final cic = context.read<ChildrenItemsCubit>();
                      cic.handleItemsChanging();
                      await item.save(titleField: titleCtr.text);
                      cic.handleItemsChanged();
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
            if (hovering == true && widget.item.isTopic)
              SizedBox(
                  width: 32,
                  child: PopupMenuButton(
                      splashRadius: 1,
                      elevation: 1,
                      padding: EdgeInsets.zero,
                      icon: const Icon(FluentIcons.more_vertical_16_regular),
                      itemBuilder: (context) {
                        final snc = context.read<SelectedNoteCubit>();
                        final cic = context.read<ChildrenItemsCubit>();
                        return <PopupMenuItem<InlineButton>>[
                          PopupMenuItem<InlineButton>(
                              onTap: () {
                                cic.handleItemsChanging();
                                widget.item.saveLocalState(
                                    newStatus: ItemVMStatus.draft);
                                cic.handleItemsChanged();
                              },
                              padding: const EdgeInsets.only(left: 8),
                              key: UniqueKey(),
                              child: InlineButton(
                                  title: 'Edit',
                                  iconData: FluentIcons.edit_16_regular,
                                  onPressed: () {})),
                          PopupMenuItem<InlineButton>(
                              onTap: () => cic.createSubTopic(widget.item),
                              padding: const EdgeInsets.only(left: 8),
                              key: UniqueKey(),
                              child: InlineButton(
                                  title: 'Add Subtopic',
                                  iconData: FluentIcons.folder_add_20_regular,
                                  onPressed: () {})),
                          PopupMenuItem<InlineButton>(
                              onTap: () async {
                                ItemVM n = await cic.createNote(widget.item);
                                snc.handleNoteChanged(n);
                              },
                              padding: const EdgeInsets.only(left: 8),
                              key: UniqueKey(),
                              child: InlineButton(
                                  title: 'Add Note',
                                  iconData: FluentIcons.note_add_20_regular,
                                  onPressed: () {})),
                          PopupMenuItem<InlineButton>(
                              onTap: () async {
                                cic.handleItemsChanging();
                                await widget.item.trash();
                                cic.handleItemsChanged();
                              },
                              padding: const EdgeInsets.only(left: 8),
                              key: UniqueKey(),
                              child: InlineButton(
                                  title: 'Move to Trash',
                                  iconData: FluentIcons.delete_20_regular,
                                  onPressed: () {})),
                        ];
                      })),
            if ((hovering == true &&
                widget.item.status == ItemVMStatus.newDraft))
              InlineButton(
                iconData: FluentIcons.dismiss_16_regular,
                onPressed: () {
                  final snc = context.read<SelectedNoteCubit>();
                  final cic = context.read<ChildrenItemsCubit>();
                  cic.handleItemsChanging();
                  if (snc.note == widget.item) {
                    snc.handleNoteChanged(null);
                  }
                  widget.item.resetState();
                  cic.removeItem(widget.item);
                  cic.handleItemsChanged();
                },
              ),
            if ((hovering == true || widget.item.pinned) &&
                isSaving != true &&
                widget.item.status != ItemVMStatus.newDraft)
              InlineButton(
                iconData: FluentIcons.pin_16_regular,
                onPressed: () async {
                  setState(() {
                    isSaving = true;
                  });
                  final cic = context.read<ChildrenItemsCubit>();
                  cic.handleItemsChanging(silent: true);
                  await widget.item.togglePinned();
                  cic.handleItemsChanged();
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
