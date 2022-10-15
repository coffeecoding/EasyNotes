import 'package:easynotes/extensions/color_ext.dart';
import 'package:easynotes/models/item.dart';
import 'package:easynotes/models/sample_data.dart';
import 'package:easynotes/screens/common/uiconstants.dart';
import 'package:easynotes/screens/items/items_screen.dart';
import 'package:easynotes/screens/note/note_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);

  static const String routeName = '/';
  final TextEditingController searchController = TextEditingController();

  static Route<dynamic> route() {
    return MaterialPageRoute<HomeScreen>(
      settings: const RouteSettings(name: routeName),
      builder: (BuildContext context) => HomeScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(
            children: [
              ElevatedButton(
                child: Row(children: [
                  const Icon(Icons.add),
                  Text('Create Topic',
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context).textTheme.bodyText1!.color)),
                ]),
                onPressed: () {},
              ),
              TextButton(
                child: Row(children: [
                  Icon(Icons.note_add,
                      color: Theme.of(context).textTheme.bodyText1!.color),
                  Text('Create Note',
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context).textTheme.bodyText1!.color)),
                ]),
                onPressed: () {},
              ),
            ],
          ),
          Container(
            width: 256,
            padding: const EdgeInsets.only(left: ConstSpacing.m),
            decoration: BoxDecoration(
                color: Theme.of(context).backgroundColor,
                borderRadius: BorderRadius.circular(8)),
            child: Row(children: [
              Expanded(
                  child: TextField(
                onChanged: (text) {},
                decoration:
                    const InputDecoration.collapsed(hintText: 'Search for ...'),
                controller: searchController,
              )),
              IconButton(
                icon: const Icon(
                  Icons.search,
                  size: 16,
                ),
                onPressed: () {},
              ),
            ]),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          )
        ]),
      ),
      body: Row(children: const [
        Expanded(flex: 1, child: ItemsScreen()),
        VerticalDivider(width: 1),
        Expanded(flex: 2, child: NoteScreen()),
      ]),
    ));
  }
}
