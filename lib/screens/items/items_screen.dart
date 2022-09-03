import 'package:easynotes/screens/items/components/notes_list.dart';
import 'package:easynotes/screens/items/components/topics_list.dart';
import 'package:flutter/material.dart';

import '../home_screen.dart';

class ItemsScreen extends StatelessWidget {
  const ItemsScreen({Key? key}) : super(key: key);

  static const String routeName = '/items';

  static Route<dynamic> route() {
    return MaterialPageRoute<HomeScreen>(
      settings: const RouteSettings(name: routeName),
      builder: (BuildContext context) => const ItemsScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(width: 100, child: TopicsList()),
      VerticalDivider(),
      Expanded(child: NotesList()),
    ]);
  }
}
