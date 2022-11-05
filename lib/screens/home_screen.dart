import 'package:easynotes/cubits/cubits.dart';
import 'package:easynotes/cubits/item_vm/item_vm.dart';
import 'package:easynotes/cubits/search/search_cubit.dart';
import 'package:easynotes/cubits/trashed_items/trashed_items_cubit.dart';
import 'package:easynotes/extensions/color_ext.dart';
import 'package:easynotes/screens/common/responsive.dart';
import 'package:easynotes/screens/common/settings_dialog.dart';
import 'package:easynotes/screens/common/toolbar_button.dart';
import 'package:easynotes/screens/common/topic_dialog.dart';
import 'package:easynotes/screens/common/uiconstants.dart';
import 'package:easynotes/screens/items/items_screen.dart';
import 'package:easynotes/screens/note/note_screen.dart';
import 'package:easynotes/screens/settings/settings_screen.dart';
import 'package:easynotes/screens/topic/topic_screen.dart';
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
        elevation: 0,
        titleSpacing: 8,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Theme.of(context).dividerColor),
        ),
        backgroundColor: Colors.transparent,
        title:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          BlocBuilder<RootItemsCubit, RootItemsState>(
            builder: (context, state) {
              RootItemsCubit ic = context.read<RootItemsCubit>();
              return Row(
                children: [
                  SizedBox(
                    width: 112,
                    child: ToolbarButton(
                        iconData: FluentIcons.add_16_regular,
                        title: 'Topic',
                        onPressed: () async {
                          TopicCubit tc = BlocProvider.of<TopicCubit>(context);
                          await ic
                              .createRootItem(0)
                              .then((cubit) => tc.select(cubit));
                          Dialog dlg = const TopicDialog(child: TopicScreen());
                          final created = await showDialog(
                              context: context, builder: (context) => dlg);
                          if (created == true) {
                            ic.insertItem(tc.topicCubit!);
                            ic.handleItemsChanged();
                          }
                        }),
                  ),
                  buildSecondaryToolbar(context),
                ],
              );
            },
          ),
          Builder(builder: (context) {
            onSearch() async {
              final ric = context.read<RootItemsCubit>();
              final cic = context.read<ChildrenItemsCubit>();
              final sl = context.read<SearchCubit>();
              await sl.search(rootItems: ric.topicCubits);
              ric.handleItemsChanging();
              ric.handleSelectionChanged(null, ChildListVisibility.search);
              cic.handleRootItemSelectionChanged(null);
            }

            return Container(
              width: 256,
              padding: const EdgeInsets.only(left: ConstSpacing.m),
              decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(4)),
              child: Row(children: [
                Expanded(
                    child: TextField(
                  onChanged: (text) =>
                      context.read<SearchCubit>().handleSearchTermChanged(text),
                  onSubmitted: (_) async => await onSearch(),
                  decoration: const InputDecoration.collapsed(
                      hintText: 'Search for ...'),
                  controller: searchController,
                )),
                IconButton(
                  icon: const Icon(
                    FluentIcons.search_20_regular,
                    size: 18,
                  ),
                  splashRadius: 1,
                  onPressed: () async => await onSearch(),
                ),
              ]),
            );
          }),
          ToolbarButton(
            iconData: FluentIcons.settings_20_regular,
            title: 'Settings',
            onPressed: () async {
              Dialog dlg = SettingsDialog(child: const SettingsScreen());
              await showDialog(context: context, builder: (context) => dlg);
            },
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

  Widget buildSecondaryToolbar(BuildContext context) {
    final ric = context.read<RootItemsCubit>();
    switch (ric.state.childListVisibility) {
      case ChildListVisibility.children:
        return BlocBuilder<ChildrenItemsCubit, ChildrenItemsState>(
          builder: (context, state) {
            final ric = context.read<RootItemsCubit>();
            if (ric.selectedItem == null) {
              return Container();
            }
            final childrenItemsCubit = context.read<ChildrenItemsCubit>();
            return Row(
              children: [
                ToolbarButton(
                    iconData: FluentIcons.folder_add_20_regular,
                    title: 'Subtopic',
                    onPressed: () =>
                        childrenItemsCubit.createSubTopic(ric.selectedItem!)),
                ToolbarButton(
                    iconData: FluentIcons.note_add_20_regular,
                    title: 'Note',
                    onPressed: () async {
                      final snc = context.read<SelectedNoteCubit>();
                      ItemVM i = await childrenItemsCubit
                          .createNote(ric.selectedItem!);
                      snc.handleNoteChanged(i);
                    }),
              ],
            );
          },
        );
      case ChildListVisibility.trash:
        final tic = context.read<TrashedItemsCubit>();
        final itemCubits = tic.items;
        return ToolbarButton(
            iconData: FluentIcons.delete_20_regular,
            enabledColor:
                itemCubits.isEmpty ? Theme.of(context).disabledColor : null,
            title: 'Clear Trash',
            onPressed: itemCubits.isEmpty
                ? null
                : () async {
                    final tic = context.read<TrashedItemsCubit>();
                    tic.handleItemsChanging();
                    await tic.deleteAll();
                    tic.handleItemsChanged(items: []);
                  });
      default:
        return Container();
    }
  }
}
