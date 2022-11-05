import 'package:easynotes/app_theme.dart';
import 'package:easynotes/cubits/cubits.dart';
import 'package:easynotes/cubits/item_vm/item_vm.dart';
import 'package:easynotes/extensions/color_ext.dart';
import 'package:easynotes/screens/common/input_label.dart';
import 'package:easynotes/screens/common/title_textfield.dart';
import 'package:easynotes/screens/common/toolbar_button.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TopicScreen extends StatefulWidget {
  const TopicScreen({super.key});

  @override
  State<TopicScreen> createState() => _TopicScreenState();
}

class _TopicScreenState extends State<TopicScreen> {
  String? selectedColor;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TopicCubit, TopicState>(
      buildWhen: (p, n) => p.status != n.status,
      builder: (context, state) {
        ItemVM? topicCubit = state.topicCubit;
        if (topicCubit == null) {
          return const SizedBox(
              height: 400,
              width: 400,
              child: Center(child: Text('No topic selected')));
        }
        final titleText =
            state.status == ItemVMStatus.newDraft || state.status == null
                ? 'Create Topic'
                : 'Edit Topic';

        FocusNode titleFN = FocusNode();
        titleFN.requestFocus();
        TextEditingController titleCtr =
            TextEditingController(text: topicCubit.titleField);
        selectedColor = topicCubit.color;
        return SizedBox(
          height: 400,
          width: 400,
          child: Stack(
            children: [
              Scaffold(
                appBar: AppBar(
                    elevation: 0,
                    titleSpacing: 0,
                    backgroundColor: Colors.transparent,
                    bottom: PreferredSize(
                      preferredSize: const Size.fromHeight(1),
                      child: Container(
                          height: 1, color: Theme.of(context).dividerColor),
                    ),
                    leading: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: ToolbarButton(
                          iconData: FluentIcons.arrow_left_16_regular,
                          title: '',
                          enabledColor: Colors.white,
                          onPressed: () => Navigator.of(context).pop(false)),
                    ),
                    title: Text(titleText),
                    actions: [
                      if (topicCubit.status != ItemVMStatus.newDraft)
                        ToolbarButton(
                            iconData: FluentIcons.delete_20_regular,
                            title: 'Trash',
                            onPressed: () async {
                              context
                                  .read<RootItemsCubit>()
                                  .handleItemsChanging(silent: true);
                              final nv = Navigator.of(context);
                              await context.read<TopicCubit>().trash();
                              nv.pop(false);
                            }),
                      ToolbarButton(
                          iconData: FluentIcons.save_20_regular,
                          title: 'Save',
                          onPressed: () async {
                            topicCubit.saveLocalState(
                                newStatus: state.status,
                                titleField: titleCtr.text,
                                contentField: '',
                                colorSelection: selectedColor);
                            context
                                .read<RootItemsCubit>()
                                .handleItemsChanging(silent: true);
                            bool s = await context.read<TopicCubit>().save(
                                title: titleCtr.text, color: selectedColor);
                            if (s && mounted) {
                              Navigator.of(context).pop(true);
                            }
                          }),
                    ]),
                body: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const InputLabel(text: 'Title:'),
                      TitleTextfield(focusNode: titleFN, controller: titleCtr),
                      const SizedBox(height: 32),
                      const InputLabel(text: 'Color:'),
                      const SizedBox(height: 8),
                      StatefulBuilder(
                          builder: ((context, setState) => GridView.count(
                                crossAxisCount: 6,
                                childAspectRatio: 1,
                                shrinkWrap: true,
                                children: <Widget>[
                                  for (Color themeColor in AppTheme.themeColors)
                                    ThemeColorButton(
                                        color: themeColor,
                                        selectedColor: Color(int.parse(
                                            selectedColor!,
                                            radix: 16)),
                                        onSelected: (v) {
                                          if (v) {
                                            selectedColor = themeColor.toHex();
                                            setState(() {});
                                          }
                                        }),
                                ],
                              )))
                    ],
                  ),
                ),
              ),
              state.status == ItemVMStatus.busy
                  ? Positioned.fill(
                      child: Container(
                          color: Colors.black54,
                          child:
                              const Center(child: CircularProgressIndicator())),
                    )
                  : Container(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHorizontalScrollable(BuildContext context,
      {required List<Widget> children}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: children),
      ),
    );
  }
}

class ThemeColorButton extends StatelessWidget {
  const ThemeColorButton({
    super.key,
    required this.color,
    required this.selectedColor,
    required this.onSelected,
  });

  final Color color;
  final Color selectedColor;
  final Function(bool)? onSelected;

  @override
  Widget build(BuildContext context) {
    final bool selected = color == selectedColor;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChipTheme(
        data: ChipThemeData.fromDefaults(
          brightness: ThemeData.estimateBrightnessForColor(color),
          secondaryColor: color,
          labelStyle: const TextStyle(),
        ).copyWith(
          backgroundColor: color,
          labelPadding: EdgeInsets.zero,
          side: selected
              ? BorderSide(color: color)
              : const BorderSide(color: Colors.transparent),
        ),
        child: ChoiceChip(
          label: Icon(
            FluentIcons.checkmark_32_filled,
            color: selected ? Colors.white : Colors.transparent,
          ),
          selected: false,
          onSelected: onSelected,
          visualDensity: const VisualDensity(
            horizontal: VisualDensity.minimumDensity,
          ),
        ),
      ),
    );
  }
}
