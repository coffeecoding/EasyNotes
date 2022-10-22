import 'package:easynotes/cubits/cubits.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'views/abstract_note_view.dart';
import 'views/simplenote_view.dart';

class NoteScreen extends StatelessWidget {
  NoteScreen({Key? key}) : super(key: key);

  static List<NoteView> draftNoteViews = [];
  static const String routeName = '/note';

  NoteView? noteView;

  static Route<dynamic> route() {
    return MaterialPageRoute<NoteScreen>(
      settings: const RouteSettings(name: routeName),
      builder: (BuildContext context) => NoteScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SelectedNoteCubit, SelectedNoteState>(
        builder: (context, state) {
      final noteCubit = state.selectedNote;
      if (noteCubit == null) {
        noteView = null;
        return const Center(child: Text('no Note selected'));
      }
      // potentially remove this: maybe we don't care ...
      // the point is to not keep overflowing memory by only ever adding
      // view items here
      // Todo: just remove this view whenever a save is successful
      draftNoteViews.removeWhere((v) => v.note.status != ItemStatus.draft);
      final drafts =
          draftNoteViews.where((v) => v.note.id == noteCubit.id).toList();
      if (drafts.isNotEmpty) {
        noteView = drafts[0];
      } else {
        switch (noteCubit.item_type) {
          default:
            noteView = SimpleNoteView(note: noteCubit);
        }
        if (noteCubit.status == ItemStatus.draft) {
          draftNoteViews.add(noteView!);
        }
      }
      return Scaffold(appBar: buildActionPanel(context), body: noteView);
    });
  }

  PreferredSizeWidget buildActionPanel(context) => AppBar(
        shadowColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        title:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(
            children: [
              TextButton(
                style: ButtonStyle(
                    padding: MaterialStateProperty.all(
                        const EdgeInsets.symmetric(horizontal: 0))),
                child: Row(children: const [
                  Icon(FontAwesomeIcons.solidTrashCan, color: Colors.red),
                  Text(' Move to Trash',
                      style: TextStyle(
                          fontWeight: FontWeight.w400, color: Colors.red)),
                ]),
                onPressed: () {},
              ),
            ],
          ),
          TextButton(
            child: Row(children: [
              Icon(FontAwesomeIcons.mapPin,
                  color: Theme.of(context).textTheme.bodyText1!.color),
              Text(' Pin Globally',
                  style: TextStyle(
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).textTheme.bodyText1!.color)),
            ]),
            onPressed: () {},
          ),
          Row(children: [
            DiscardButton(key: UniqueKey()),
            SaveButton(key: UniqueKey(), noteView: noteView!),
          ]),
        ]),
      );
}

class DiscardButton extends StatelessWidget {
  const DiscardButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SelectedNoteCubit, SelectedNoteState>(
        buildWhen: (p, n) => p.status != n.status,
        builder: (context, state) {
          return ActionButton(
              iconData: Icons.cancel,
              onPressed: () => state.selectedNote!.resetState(),
              enabled: state.status != SelectedNoteStatus.persisted,
              title: 'Discard');
        });
  }
}

class SaveButton extends StatelessWidget {
  const SaveButton({super.key, required this.noteView});

  final NoteView noteView;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SelectedNoteCubit, SelectedNoteState>(
        buildWhen: (p, n) => p.status != n.status,
        builder: (context, state) {
          switch (state.status) {
            case SelectedNoteStatus.busy:
              return const Center(child: CircularProgressIndicator());
            default:
              return ActionButton(
                  iconData: Icons.save,
                  onPressed: () {
                    noteView.saveLocalState(context);
                    //state.selectedNote!.save();
                    context.read<SelectedNoteCubit>().save();
                  },
                  enabled: state.status != SelectedNoteStatus.persisted,
                  title: 'Save');
          }
        });
  }
}

class ActionButton extends StatelessWidget {
  const ActionButton(
      {super.key,
      this.onPressed,
      required this.iconData,
      required this.title,
      this.enabled = true});

  final Function()? onPressed;
  final bool enabled;
  final IconData iconData;
  final String title;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: enabled ? onPressed : null,
      child: Row(children: [
        Icon(iconData,
            color: enabled
                ? Theme.of(context).textTheme.bodyText1!.color
                : Theme.of(context).disabledColor),
        Text(title,
            style: TextStyle(
                fontWeight: FontWeight.w400,
                color: enabled
                    ? Theme.of(context).textTheme.bodyText1!.color
                    : Theme.of(context).disabledColor)),
      ]),
    );
  }
}
