import 'package:easynotes/cubits/cubits.dart';
import 'package:easynotes/cubits/item/item_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'abstract_note_view.dart';

class SimpleNoteView extends StatefulWidget implements NoteView {
  SimpleNoteView({super.key, required this.note})
      : titleCtr = TextEditingController(text: note.title),
        contentCtr = TextEditingController(text: note.content) {}

  @override
  ItemCubit note;
  final TextEditingController titleCtr;
  final TextEditingController contentCtr;
  late FocusNode contentFN = FocusNode();
  late FocusNode titleFN = FocusNode();
  FocussedElement? focussedElement;

  @override
  State<SimpleNoteView> createState() => _SimpleNoteViewState();
}

class _SimpleNoteViewState extends State<SimpleNoteView> {
  @override
  void initState() {
    super.initState();
    widget.contentFN.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(children: [
        TextField(
            onChanged: (n) => ensureStateIsDraft(titleDraft: n),
            onEditingComplete: () => widget.contentFN.requestFocus(),
            toolbarOptions: const ToolbarOptions(
                paste: true, copy: true, selectAll: true, cut: true),
            onTap: () {
              widget.contentFN.unfocus();
              widget.focussedElement = FocussedElement.title;
            },
            focusNode: widget.titleFN,
            controller: widget.titleCtr),
        Expanded(
            child: TextField(
                onChanged: (n) => ensureStateIsDraft(contentDraft: n),
                toolbarOptions: const ToolbarOptions(
                    paste: true, copy: true, selectAll: true, cut: true),
                onTap: () {
                  widget.titleFN.unfocus();
                  widget.focussedElement = FocussedElement.content;
                },
                focusNode: widget.contentFN,
                controller: widget.contentCtr,
                maxLines: null)),
      ]),
    );
  }

  // Todo: Add everything else too, like options etc, once they are implemented
  void ensureStateIsDraft({String? titleDraft, String? contentDraft}) {
    ItemCubit? noteCubit = BlocProvider.of<ItemsCubit>(context).selectedNote;
    if (noteCubit!.status != ItemStatus.draft) {
      noteCubit.saveLocalState(
        newStatus: ItemStatus.draft,
      );
    }
  }

  @override
  void didUpdateWidget(SimpleNoteView oldView) {
    super.didUpdateWidget(oldView);
  }
}
