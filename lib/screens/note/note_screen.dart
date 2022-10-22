import 'package:easynotes/cubits/cubits.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

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
        toolbarHeight: 40,
        elevation: 0,
        titleSpacing: 8,
        backgroundColor: Colors.black12,
        title:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          ActionButton(
              iconData: FluentIcons.delete_20_regular,
              title: 'Move to Trash',
              enabled: true,
              onPressed: () {}),
          ActionButton(
              iconData: FluentIcons.pin_20_regular,
              title: 'Pin Globally',
              enabled: true,
              onPressed: () {}),
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
              iconData: FluentIcons.dismiss_16_regular,
              onPressed: () => state.selectedNote!.resetState(),
              enabled: state.status != ItemStatus.persisted,
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
            case ItemStatus.busy:
              return const Center(child: CircularProgressIndicator());
            default:
              return ActionButton(
                  iconData: FluentIcons.save_16_regular,
                  onPressed: () {
                    noteView.saveLocalState(context);
                    //state.selectedNote!.save();
                    context.read<SelectedNoteCubit>().save();
                  },
                  enabled: state.status != ItemStatus.persisted,
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
      child: Row(
        children: [
          Icon(iconData,
              color:
                  enabled ? Colors.white70 : Theme.of(context).disabledColor),
          const SizedBox(width: 4),
          Text(title,
              style: TextStyle(
                  fontWeight: FontWeight.w400,
                  color: enabled
                      ? Colors.white70
                      : Theme.of(context).disabledColor)),
        ],
      ),
    );
  }
}
