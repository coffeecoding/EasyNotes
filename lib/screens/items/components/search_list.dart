import 'package:easynotes/cubits/cubits.dart';
import 'package:easynotes/cubits/search/search_cubit.dart';
import 'package:easynotes/screens/common/toolbar_button.dart';
import 'package:easynotes/screens/items/components/widgets/list_item.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchList extends StatelessWidget {
  const SearchList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchCubit, SearchState>(builder: (context, state) {
      final itemCubits = state.results;
      if (itemCubits.isEmpty) {
        return const Center(child: Text('No matching results'));
      }
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
                      title: 'Trash All',
                      onPressed: () {}),
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
                      return ExpandableItemContainer(
                          color: Color(int.parse(item.color, radix: 16)),
                          item: item);
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
