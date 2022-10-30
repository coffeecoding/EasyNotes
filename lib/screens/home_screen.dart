import 'package:easynotes/cubits/cubits.dart';
import 'package:easynotes/cubits/item_vm/item_vm.dart';
import 'package:easynotes/cubits/search/search_cubit.dart';
import 'package:easynotes/extensions/color_ext.dart';
import 'package:easynotes/models/item.dart';
import 'package:easynotes/config/sample_data.dart';
import 'package:easynotes/screens/common/responsive.dart';
import 'package:easynotes/screens/common/styles.dart';
import 'package:easynotes/screens/common/toolbar_button.dart';
import 'package:easynotes/screens/common/uiconstants.dart';
import 'package:easynotes/screens/items/items_screen.dart';
import 'package:easynotes/screens/note/note_screen.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
        titleSpacing: 8,
        title:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(
            children: [
              ToolbarButton(
                iconData: FluentIcons.settings_20_regular,
                title: 'Settings',
                enabledColor: Colors.white70,
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
                onChanged: (text) =>
                    context.read<SearchCubit>().handleSearchTermChanged(text),
                onSubmitted: (_) async {
                  final ric = context.read<RootItemsCubit>();
                  final cic = context.read<ChildrenItemsCubit>();
                  final sl = context.read<SearchCubit>();
                  await sl.search(rootItems: ric.topicCubits);
                  ric.handleItemsChanging();
                  ric.handleSelectionChanged(null, ChildListVisibility.search);
                  cic.handleRootItemSelectionChanged(null);
                },
                decoration:
                    const InputDecoration.collapsed(hintText: 'Search for ...'),
                controller: searchController,
              )),
              IconButton(
                icon: const Icon(
                  FluentIcons.search_20_regular,
                  size: 18,
                ),
                splashRadius: 1,
                onPressed: () async {
                  final ric = context.read<RootItemsCubit>();
                  final cic = context.read<ChildrenItemsCubit>();
                  final sl = context.read<SearchCubit>();
                  await sl.search(rootItems: ric.topicCubits);
                  ric.handleItemsChanging();
                  ric.handleSelectionChanged(null, ChildListVisibility.search);
                  cic.handleRootItemSelectionChanged(null);
                },
              ),
            ]),
          ),
        ]),
      ),
      body: Row(children: [
        const Expanded(flex: 1, child: ItemsScreen()),
        const VerticalDivider(width: 1),
        if (Responsive.isDesktop(context))
          Expanded(flex: 2, child: NoteScreen()),
      ]),
    ));
  }
}
