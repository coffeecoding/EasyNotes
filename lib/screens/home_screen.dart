import 'package:easynotes/extensions/color_ext.dart';
import 'package:easynotes/models/item.dart';
import 'package:easynotes/config/sample_data.dart';
import 'package:easynotes/screens/common/styles.dart';
import 'package:easynotes/screens/common/uiconstants.dart';
import 'package:easynotes/screens/items/items_screen.dart';
import 'package:easynotes/screens/note/note_screen.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
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
        toolbarHeight: 64,
        elevation: 1,
        title:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(
            children: [
              ElevatedButton(
                style: const ENPrimaryButtonStyle(),
                child: Row(children: [
                  const Icon(FluentIcons.folder_add_20_regular),
                  const SizedBox(width: 4),
                  Text('Create Topic',
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context).textTheme.bodyText1!.color)),
                ]),
                onPressed: () {},
              ),
              TextButton(
                child: Row(children: [
                  Icon(FluentIcons.note_add_20_regular,
                      color: Theme.of(context).textTheme.bodyText1!.color),
                  const SizedBox(width: 4),
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
                color: Colors.black26, borderRadius: BorderRadius.circular(4)),
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
                  FluentIcons.search_20_regular,
                  size: 16,
                ),
                onPressed: () {},
              ),
            ]),
          ),
          IconButton(
            icon: const Icon(FluentIcons.settings_20_regular),
            onPressed: () {},
          )
        ]),
      ),
      body: Row(children: [
        const Expanded(flex: 1, child: ItemsScreen()),
        const VerticalDivider(width: 1),
        Expanded(flex: 2, child: NoteScreen()),
      ]),
    ));
  }
}
