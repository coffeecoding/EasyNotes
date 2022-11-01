import 'package:easynotes/cubits/cubits.dart';
import 'package:easynotes/cubits/item_vm/item_vm.dart';
import 'package:easynotes/extensions/color_ext.dart';
import 'package:easynotes/screens/common/toolbar_button.dart';
import 'package:easynotes/screens/items/components/widgets/list_item.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChildrenList extends StatelessWidget {
  const ChildrenList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChildrenItemsCubit, ChildrenItemsState>(
        builder: (context, state) {
      final selectedRootItem = context.read<RootItemsCubit>().selectedItem;
      //if (state.status == ChildrenItemsStatus.unselected) {
      if (selectedRootItem == null) {
        return const Center(child: Text('No Topic selected'));
      }
      final childrenItemsCubit = context.read<ChildrenItemsCubit>();
      final itemCubits = state.childrenCubits;
      final clr = HexColor.fromHex(selectedRootItem.color);
      return Scaffold(
          appBar: AppBar(
              titleSpacing: 8,
              toolbarHeight: 40,
              backgroundColor: Colors.black12,
              elevation: 0,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ToolbarButton(
                      iconData: FluentIcons.folder_add_20_regular,
                      title: 'Subtopic',
                      onPressed: () =>
                          childrenItemsCubit.createSubTopic(selectedRootItem)),
                  ToolbarButton(
                      iconData: FluentIcons.note_add_20_regular,
                      title: 'Note',
                      onPressed: () async {
                        final snc = context.read<SelectedNoteCubit>();
                        ItemVM i = await childrenItemsCubit
                            .createNote(selectedRootItem);
                        snc.handleNoteChanged(i);
                      }),
                ],
              )),
          body: Container(
            alignment: Alignment.topLeft,
            child: Stack(
              children: [
                ListView.builder(
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    itemCount: itemCubits.length,
                    itemBuilder: (context, i) {
                      final item = itemCubits[i];
                      return ExpandableItemContainer(color: clr, item: item);
                    }),
                state.status == ChildrenItemsStatus.busy
                    ? Positioned.fill(
                        child: Container(
                            color: Colors.black26,
                            child: const Center(
                                child: CircularProgressIndicator())))
                    : Container(),
              ],
            ),
          ));
    });
  }
}
