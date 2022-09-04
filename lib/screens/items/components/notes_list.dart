import 'package:easynotes/cubits/cubits.dart';
import 'package:easynotes/extensions/color_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotesList extends StatefulWidget {
  const NotesList({Key? key}) : super(key: key);

  @override
  State<NotesList> createState() => _NotesListState();
}

class _NotesListState extends State<NotesList> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ItemsCubit, ItemsState>(
        buildWhen: (prev, next) => prev.topic != next.topic,
        builder: (context, state) {
          print("building notes list");
          if (state.topic == null) {
            return const Center(child: Text('No topic selected'));
          }
          final noteCubits = state.topic!.state.notes;
          switch (state.topic!.state.status) {
            case TopicStatus.waiting:
              return const Center(child: CircularProgressIndicator());
            case TopicStatus.error:
              return const Center(child: Text('Sum went wrong ...'));
            default:
              return ListView.builder(
                  itemCount: noteCubits.length,
                  itemBuilder: (context, i) {
                    final note = noteCubits[i].state.note;
                    return Container(
                        decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: Theme.of(context).cardColor,
                                  width: 1)),
                        ),
                        child: ListTile(
                          onTap: () => print("tapped " + note!.title),
                          title: Center(child: Text(note!.title)),
                        ));
                  });
          }
        });
  }
}
