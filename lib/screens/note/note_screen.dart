import 'package:easynotes/cubits/cubits.dart';
import 'package:easynotes/extensions/color_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'views/simplenote_view.dart';

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
    return BlocBuilder<ItemsCubit, ItemsState>(
        buildWhen: (p, n) => p.selectedNote != n.selectedNote,
        builder: (context, state) {
          final noteCubit = state.selectedNote;
          if (noteCubit == null) {
            return const Center(child: Text('no Note selected'));
          }
          Widget? body;
          switch (noteCubit.item_type) {
            case 1:
              body = SimpleNoteView(note: noteCubit);
              break;
            default:
              body = Center(child: Text(noteCubit.item.title));
              break;
          }
          return Scaffold(appBar: buildActionPanel(context), body: body);
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
            TextButton(
              child: Row(children: [
                Icon(Icons.cancel,
                    color: Theme.of(context).textTheme.bodyText1!.color),
                Text(' Discard Changes',
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).textTheme.bodyText1!.color)),
              ]),
              onPressed: () {},
            ),
            TextButton(
              child: Row(children: [
                Icon(Icons.save,
                    color: Theme.of(context).textTheme.bodyText1!.color),
                Text(' Save',
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).textTheme.bodyText1!.color)),
              ]),
              onPressed: () {},
            ),
          ]),
        ]),
      );
}
