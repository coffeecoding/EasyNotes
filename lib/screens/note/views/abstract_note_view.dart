import 'package:easynotes/cubits/item_vm/item_vm.dart';
import 'package:flutter/cupertino.dart';

abstract class NoteView extends Widget {
  const NoteView({dynamic key});

  ItemVM get note;
  String get titleField;
  String get contentField;
  String get colorSelection;

  void saveLocalState(BuildContext context);
}
