import 'package:easynotes/cubits/item/item_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class SimpleNoteView extends StatelessWidget {
  const SimpleNoteView({super.key, required this.note});

  final ItemCubit note;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(note.title));
  }
}
