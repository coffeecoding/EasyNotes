import 'package:easynotes/cubits/item/item_cubit.dart';
import 'package:flutter/cupertino.dart';

abstract class NoteView extends Widget {
  const NoteView({dynamic key});

  ItemCubit get note;

  void saveLocalState();
}
