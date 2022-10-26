import 'package:easynotes/cubits/cubits.dart';
import 'package:easynotes/cubits/item_vm/item_vm.dart';
import 'package:easynotes/extensions/color_ext.dart';
import 'package:easynotes/screens/common/inline_button.dart';
import 'package:easynotes/screens/common/toolbar_button.dart';
import 'package:easynotes/screens/common/topic_dialog.dart';
import 'package:easynotes/screens/topic/topic_screen.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TopicsList extends StatelessWidget {
  const TopicsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          toolbarHeight: 40,
          backgroundColor: Colors.black12,
          elevation: 0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ToolbarButton(
                  iconData: FluentIcons.folder_add_20_filled,
                  title: 'Topic',
                  onPressed: () async {
                    RootItemsCubit ic =
                        BlocProvider.of<RootItemsCubit>(context);
                    TopicCubit tc = BlocProvider.of<TopicCubit>(context);
                    await ic
                        .createRootItem(0)
                        .then((cubit) => tc.select(cubit));
                    Dialog dlg = const TopicDialog(child: TopicScreen());
                    final created = await showDialog(
                        context: context, builder: (context) => dlg);
                    if (created != null && created == true) {
                      ic.insertItem(tc.topicCubit!);
                    }
                  }),
            ],
          )),
      body: BlocBuilder<RootItemsCubit, RootItemsState>(
          buildWhen: (prev, next) =>
              prev.status != next.status ||
              prev.selectedItem != next.selectedItem ||
              prev.topicCubits != next.topicCubits,
          builder: (context, state) {
            final topics = state.topicCubits;
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ListView.builder(
                            shrinkWrap: true,
                            itemCount: topics.length,
                            itemBuilder: (context, idx) {
                              final topic = topics[idx];
                              final clr = HexColor.fromHex(topic.color);
                              return RootItemContainer(
                                  key: UniqueKey(),
                                  item: topic,
                                  selectedItem: state.selectedItem,
                                  color: clr);
                            }),
                        Container(
                          color: Colors.transparent,
                          height: 128,
                          child: DragTarget<ItemVM>(
                              onWillAccept: (itemCubit) =>
                                  itemCubit != null &&
                                  itemCubit.isTopic &&
                                  itemCubit.parent != null,
                              onAccept: (incomingItem) async {
                                // ! This is root drag target (not root item) !
                                final cic = context.read<ChildrenItemsCubit>();
                                final ric = context.read<RootItemsCubit>();
                                await incomingItem.changeParent(
                                    newParent: null, ric: ric, cic: cic);
                              },
                              builder: (context, __, ___) => Container()),
                        ),
                      ],
                    ),
                  ),
                ),
                TrashContainer(key: UniqueKey())
              ],
            );
          }),
    );
  }
}

class TrashContainer extends StatelessWidget {
  const TrashContainer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<ItemVM>(
        onWillAccept: (itemCubit) => itemCubit != null,
        onAccept: (itemCubit) {},
        builder: (context, __, ___) {
          RootItemsCubit ic = context.read<RootItemsCubit>();
          return Container(
            decoration: BoxDecoration(
                color: true ? Colors.white10 : Colors.transparent,
                border: true
                    ? const Border(
                        right: BorderSide(color: Colors.white70, width: 2))
                    : null),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              trailing: null,
              onTap: () {},
              title: Stack(
                alignment: Alignment.center,
                children: [
                  Column(children: const [
                    Icon(FluentIcons.delete_24_filled, color: Colors.white70),
                    /*Text('Trash',
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            color: Colors.white70)),*/
                  ]),
                ],
              ),
            ),
          );
        });
  }
}

class RootItemContainer extends StatelessWidget {
  const RootItemContainer({
    super.key,
    required this.item,
    required this.selectedItem,
    required this.color,
  });

  final ItemVM item;
  final ItemVM? selectedItem;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DragTarget<ItemVM>(
      onWillAccept: (itemCubit) =>
          itemCubit != null && itemCubit.parent != item && itemCubit != item,
      onAccept: (incomingItem) async {
        final cic = context.read<ChildrenItemsCubit>();
        final ric = context.read<RootItemsCubit>();
        await incomingItem.changeParent(newParent: item, ric: ric, cic: cic);
      },
      builder: (context, __, ___) => Draggable(
        data: item,
        feedback: Material(
          child: Container(
            color: Colors.black26,
            width: 100,
            height: 50,
            child: RootItemRow(
                selectedItem: selectedItem, item: item, color: color),
          ),
        ),
        child:
            RootItemRow(selectedItem: selectedItem, item: item, color: color),
      ),
    );
  }
}

class RootItemRow extends StatefulWidget {
  const RootItemRow(
      {super.key,
      required this.item,
      required this.selectedItem,
      required this.color});

  final ItemVM item;
  final ItemVM? selectedItem;
  final Color color;

  @override
  State<RootItemRow> createState() => _RootItemRowState();
}

class _RootItemRowState extends State<RootItemRow> {
  bool? hovering;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: (widget.selectedItem != null &&
                  widget.item == widget.selectedItem)
              ? Colors.white10
              : Colors.transparent,
          border: (widget.selectedItem != null &&
                  widget.item == widget.selectedItem!)
              ? Border(right: BorderSide(color: widget.color, width: 2))
              : null),
      child: MouseRegion(
        onEnter: (PointerEvent e) => setState(() {
          hovering = true;
        }),
        onExit: (PointerEvent e) => setState(() {
          hovering = false;
        }),
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          trailing: null,
          onTap: () {
            context.read<RootItemsCubit>().handleSelectionChanged(widget.item);
            context
                .read<ChildrenItemsCubit>()
                .handleRootItemSelectionChanged(widget.item);
          },
          title: Stack(
            alignment: Alignment.center,
            children: [
              Column(children: [
                Icon(FluentIcons.folder_20_filled, color: widget.color),
                Text(widget.item.title,
                    style: TextStyle(
                        fontWeight: FontWeight.w400, color: widget.color)),
              ]),
              if (hovering == true)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InlineButton(
                      iconData: FluentIcons.edit_16_regular,
                      onPressed: () async {
                        RootItemsCubit ic =
                            BlocProvider.of<RootItemsCubit>(context);
                        TopicCubit tc = BlocProvider.of<TopicCubit>(context);
                        tc.select(widget.item);
                        Dialog dlg = const TopicDialog(child: TopicScreen());
                        final changes = await showDialog(
                            context: context, builder: (context) => dlg);
                        if (changes == true) {
                          ic.handleItemsChanged();
                        }
                      },
                    ),
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }
}
