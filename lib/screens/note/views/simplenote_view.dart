import 'package:easynotes/cubits/cubits.dart';
import 'package:easynotes/cubits/item/item_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SimpleNoteView extends StatefulWidget {
  SimpleNoteView({super.key, required this.note})
      : titleCtr = TextEditingController(text: note.titleField) {
    contentCtr = TextEditingController(text: decodeContent());
    contentCtr.selection = TextSelection(
        baseOffset: note.contentBaseOffset,
        extentOffset: note.contentExtentOffset);
    switch (note.focussedElement) {
      case FocussedElement.title:
        titleFN.requestFocus();
        break;
      case FocussedElement.content:
        contentFN.requestFocus();
        break;
      default:
        break;
    }
  }

  final ItemCubit note;
  final TextEditingController titleCtr;
  late TextEditingController contentCtr;
  late FocusNode contentFN = FocusNode();
  late FocusNode titleFN = FocusNode();

  // Todo: potentially refactor this method interface into
  String decodeContent() => note.contentField;

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
        TextField(focusNode: widget.titleFN, controller: widget.titleCtr),
        Expanded(
            child: TextField(
                focusNode: widget.contentFN,
                controller: widget.contentCtr,
                maxLines: null)),
      ]),
    );
  }

  @override
  void didUpdateWidget(SimpleNoteView oldView) {
    super.didUpdateWidget(oldView);
    oldView.note.saveLocalState(
        title: oldView.titleCtr.text,
        content: oldView.contentCtr.text,
        contentExtentOffset: oldView.contentCtr.selection.extentOffset,
        contentBaseOffset: oldView.contentCtr.selection.baseOffset,
        focussedElement: oldView.titleFN.hasFocus
            ? FocussedElement.title
            : oldView.contentFN.hasFocus
                ? FocussedElement.content
                : null);
  }
}
