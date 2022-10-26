import 'package:easynotes/cubits/cubits.dart';
import 'package:easynotes/cubits/item_vm/item_vm.dart';
import 'package:easynotes/screens/common/toolbar_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      draftNoteViews.removeWhere((v) => v.note.status != ItemVMStatus.draft);
      final drafts = draftNoteViews.where((v) => v.note == noteCubit).toList();
      if (drafts.isNotEmpty) {
        noteView = drafts[0];
      } else {
        switch (noteCubit.item_type) {
          default:
            noteView = SimpleNoteView(note: noteCubit);
        }
        if (noteCubit.status == ItemVMStatus.draft) {
          draftNoteViews.add(noteView!);
        }
      }
      return Scaffold(
          key: UniqueKey(),
          appBar: buildActionPanel(context),
          body: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      noteCubit
                          .getAncestors()
                          .reversed
                          .map((e) => e.title)
                          .join(' > '),
                      textAlign: TextAlign.start,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
              Expanded(child: noteView!),
            ],
          ));
    });
  }

  PreferredSizeWidget buildActionPanel(context) => AppBar(
        toolbarHeight: 40,
        elevation: 0,
        titleSpacing: 8,
        backgroundColor: Colors.black12,
        title:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          ToolbarButton(
              iconData: FluentIcons.delete_20_regular,
              title: 'Move to Trash',
              enabledColor: Colors.red,
              enabled: true,
              onPressed: () {}),
          /*ToolbarButton(
              iconData: FluentIcons.pin_20_regular,
              title: 'Pin Globally',
              enabled: true,
              onPressed: () {}),*/
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
          return ToolbarButton(
              iconData: FluentIcons.dismiss_16_regular,
              onPressed: () {
                context.read<SelectedNoteCubit>().resetState();
                context.read<ChildrenItemsCubit>().handleItemsChanged();
              },
              enabled: state.status != ItemVMStatus.persisted,
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
            case ItemVMStatus.busy:
              return const Center(child: CircularProgressIndicator());
            default:
              return ToolbarButton(
                  key: UniqueKey(),
                  iconData: FluentIcons.save_16_regular,
                  onPressed: () async {
                    noteView.saveLocalState(context);
                    final cic = context.read<ChildrenItemsCubit>();
                    final snc = context.read<SelectedNoteCubit>();
                    await snc.save(
                      titleField: noteView.titleField,
                      contentField: noteView.contentField,
                    );
                    cic.handleItemsChanged();
                  },
                  enabled: state.status != ItemVMStatus.persisted,
                  title: 'Save');
          }
        });
  }
}
