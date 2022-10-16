import 'package:easynotes/cubits/cubits.dart';
import 'package:easynotes/cubits/item/item_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SimpleNoteView extends StatefulWidget {
  SimpleNoteView({super.key, required this.note})
      : titleCtr = TextEditingController(text: note.titleField) {
    contentCtr = TextEditingController(text: decodeContent());
  }

  final ItemCubit note;
  final TextEditingController titleCtr;
  late TextEditingController contentCtr;

  // Todo: potentially refactor this method interface into
  String decodeContent() => note.contentField;

  @override
  State<SimpleNoteView> createState() => _SimpleNoteViewState();
}

class _SimpleNoteViewState extends State<SimpleNoteView> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(children: [
        TextField(controller: widget.titleCtr),
        Expanded(
            child: TextField(controller: widget.contentCtr, maxLines: null)),
      ]),
    );
  }

  @override
  void didUpdateWidget(SimpleNoteView oldView) {
    super.didUpdateWidget(oldView);
    oldView.note.saveLocalState(
        title: oldView.titleCtr.text, content: oldView.contentCtr.text);
  }
}
