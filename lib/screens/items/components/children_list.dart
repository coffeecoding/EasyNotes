import 'package:easynotes/cubits/cubits.dart';
import 'package:easynotes/extensions/color_ext.dart';
import 'package:easynotes/screens/items/components/widgets/list_item.dart';
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
      final itemCubits = state.childrenCubits;
      final clr = HexColor.fromHex(selectedRootItem.color);
      return Container(
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
                        child:
                            const Center(child: CircularProgressIndicator())))
                : Container(),
          ],
        ),
      );
    });
  }
}
