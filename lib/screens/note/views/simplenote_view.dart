import 'package:easynotes/cubits/cubits.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'abstract_note_view.dart';

class SimpleNoteView extends StatefulWidget implements NoteView {
  SimpleNoteView({super.key, required this.note})
      : titleCtr = TextEditingController(text: note.state.titleField),
        contentCtr = TextEditingController(text: note.state.contentField);

  @override
  ItemCubit note;
  final TextEditingController titleCtr;
  final TextEditingController contentCtr;
  late FocusNode contentFN = FocusNode();
  late FocusNode titleFN = FocusNode();
  FocussedElement? focussedElement;

  @override
  void saveLocalState(BuildContext context) {
    BlocProvider.of<SelectedNoteCubit>(context).saveLocalState(
        newStatus: ItemStatus.draft,
        titleField: titleCtr.text,
        contentField: contentCtr.text);
  }

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
            onChanged: (_) => ensureStateIsDraft(context),
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
                onChanged: (_) => ensureStateIsDraft(context),
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
  void ensureStateIsDraft(BuildContext context) {
    if (widget.note.status == ItemStatus.newDraft) return;
    if (widget.note.status != ItemStatus.draft) widget.saveLocalState(context);
  }

  @override
  void didUpdateWidget(SimpleNoteView oldView) {
    super.didUpdateWidget(oldView);
  }
}
