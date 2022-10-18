import 'package:easynotes/cubits/cubits.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'abstract_note_view.dart';

class SimpleNoteView extends StatefulWidget implements NoteView {
  SimpleNoteView({super.key, required this.note})
      : titleCtr = TextEditingController(text: note.title),
        contentCtr = TextEditingController(text: note.content);

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
    Widget result = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(children: [
        TextField(
            cursorWidth: 1,
            decoration: InputDecoration(
                hoverColor: Colors.green,
                focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(width: 0, color: Colors.purple)),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        width: 1.0 /
                            MediaQuery.of(context)
                                .devicePixelRatio, // this is how to generally achieve 1 pixel width in Flutter
                        color: Theme.of(context).dividerColor))),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w100),
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
        const SizedBox(height: 16),
        Expanded(
            child: TextField(
                cursorWidth: 1,
                decoration: null,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.w100),
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
    if (widget.focussedElement == FocussedElement.title) {
      widget.titleFN.requestFocus();
    } else {
      widget.contentFN.requestFocus();
    }
    return result;
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
