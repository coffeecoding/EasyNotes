import 'package:easynotes/cubits/cubits.dart';
import 'package:easynotes/cubits/item/item_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SimpleNoteView extends StatefulWidget {
  SimpleNoteView({super.key, required this.note})
      : titleCtr = TextEditingController(text: note.titleField) {
    contentCtr = TextEditingController(text: note.contentField);
    contentCtr.selection = TextSelection(
        baseOffset: note.contentBaseOffset,
        extentOffset: note.contentExtentOffset);
    focussedElement = note.focussedElement;
    switch (focussedElement) {
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
            toolbarOptions: const ToolbarOptions(
                paste: true, copy: true, selectAll: true, cut: true),
            onTap: () => widget.focussedElement = FocussedElement.title,
            focusNode: widget.titleFN,
            controller: widget.titleCtr),
        Expanded(
            child: TextField(
                onChanged: (n) => ensureStateIsDraft(contentDraft: n),
                toolbarOptions: const ToolbarOptions(
                    paste: true, copy: true, selectAll: true, cut: true),
                onTap: () => widget.focussedElement = FocussedElement.content,
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
      noteCubit.setToDraft();
    }
  }

  @override
  void didUpdateWidget(SimpleNoteView oldView) {
    super.didUpdateWidget(oldView);
    // without this condition, when discarding changes, the fields won't reset
    // because the local state of the text controllers is copied again and saved
    // in the rspective cubit
    if (oldView.note.status == ItemStatus.draft) {
      oldView.note.saveLocalState(
          title: oldView.titleCtr.text,
          content: oldView.contentCtr.text,
          contentExtentOffset: oldView.contentCtr.selection.extentOffset,
          contentBaseOffset: oldView.contentCtr.selection.baseOffset,
          focussedElement: oldView.focussedElement);
    }
  }
}
