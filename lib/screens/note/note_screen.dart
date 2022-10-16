import 'package:easynotes/cubits/cubits.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NoteScreen extends StatelessWidget {
  const NoteScreen({Key? key}) : super(key: key);

  static const String routeName = '/note';

  static Route<dynamic> route() {
    return MaterialPageRoute<NoteScreen>(
      settings: const RouteSettings(name: routeName),
      builder: (BuildContext context) => const NoteScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ItemsCubit, ItemsState>(builder: (context, state) {
      final selectedItemCubit = state.selectedNote;
      if (selectedItemCubit == null) {
        return const Center(child: Text('no Note selected'));
      }
      return Center(child: Text(selectedItemCubit!.item.title));
    });
  }
}
