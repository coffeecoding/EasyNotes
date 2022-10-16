import 'package:easynotes/cubits/cubits.dart';
import 'package:easynotes/extensions/color_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotesList extends StatelessWidget {
  const NotesList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ItemsCubit, ItemsState>(
        // potentially add condition to rebuild when changing a node's parent
        buildWhen: (prev, next) =>
            prev.selectedNote != next.selectedNote ||
            prev.selectedTopic != next.selectedTopic ||
            prev.selectedSubTopic != next.selectedSubTopic,
        builder: (context, state) {
          final selectedTopic = state.selectedSubTopic;
          if (selectedTopic == null) {
            return const Center(child: Text('No Topic selected'));
          }
          final itemCubits = selectedTopic.children;
          final clr = HexColor.fromHex(selectedTopic.color);
          return ListView.builder(
              itemCount: itemCubits.length,
              itemBuilder: (context, i) {
                final item = itemCubits[i];
                return Container(
                    padding: EdgeInsets.only(
                        left: (item.getAncestorCount() - 1) * 20),
                    decoration: BoxDecoration(
                      color: (state.selectedNote != null &&
                              itemCubits[i].id == state.selectedNote!.id)
                          ? Theme.of(context).cardColor
                          : Colors.transparent,
                      border: Border(
                          bottom: BorderSide(
                              color: Theme.of(context).cardColor, width: 1)),
                    ),
                    child: ListTile(
                      onTap: () => context.read<ItemsCubit>().selectNote(i),
                      title: Row(children: [
                        Icon(
                            item.item_type == 0
                                ? Icons.folder
                                : Icons.note_outlined,
                            color: clr),
                        const SizedBox(width: 10),
                        Text(item.title),
                      ]),
                    ));
              });
        });
  }
}
