import 'package:easynotes/app_theme.dart';
import 'package:easynotes/cubits/cubits.dart';
import 'package:easynotes/screens/common/input_label.dart';
import 'package:easynotes/screens/common/title_textfield.dart';
import 'package:easynotes/screens/common/toolbar_button.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TopicScreen extends StatelessWidget {
  const TopicScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TopicCubit, TopicState>(
      builder: (context, state) {
        final titleText =
            state.status == ItemStatus.newDraft || state.status == null
                ? 'Create Topic'
                : 'Edit Topic "${state.topicCubit?.title}"';

        FocusNode titleFN = FocusNode();
        titleFN.requestFocus();
        TextEditingController titleCtr = TextEditingController();
        titleCtr.selection = TextSelection(
            baseOffset: state.topicCubit!.title.length, extentOffset: 0);
        String color = state.topicCubit!.color;
        return SizedBox(
          height: 400,
          width: 400,
          child: Stack(
            children: [
              Scaffold(
                appBar: AppBar(
                    elevation: 1,
                    titleSpacing: 0,
                    leading: ToolbarButton(
                        iconData: FluentIcons.arrow_left_16_regular,
                        title: '',
                        enabledColor: Colors.white,
                        onPressed: () => Navigator.of(context).pop(false)),
                    title: Text(titleText),
                    actions: [
                      if (state.topicCubit!.status != ItemStatus.newDraft)
                        ToolbarButton(
                            iconData: FluentIcons.delete_20_regular,
                            title: 'Trash',
                            onPressed: () {}),
                      ToolbarButton(
                          iconData: FluentIcons.save_20_regular,
                          title: 'Save',
                          onPressed: () => context
                              .read<TopicCubit>()
                              .save()
                              .then((value) =>
                                  () => Navigator.of(context).pop(value))),
                    ]),
                body: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const InputLabel(text: 'Title:'),
                      TitleTextfield(focusNode: titleFN),
                      const SizedBox(height: 32),
                      const InputLabel(text: 'Color:'),
                      const SizedBox(height: 8),
                      GridView.count(
                        crossAxisCount: 6,
                        childAspectRatio: 1,
                        shrinkWrap: true,
                        children: <Widget>[
                          for (Color themeColor in AppTheme.themeColors)
                            ThemeColorButton(
                                color: themeColor,
                                selectedColor:
                                    Color(int.parse(color, radix: 16))),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              state.status == ItemStatus.busy
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
    Color? color,
    required this.selectedColor,
  }) : color = color ?? const Color(0xFFA9B852);

  final Color color;
  final Color selectedColor;

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
            FluentIcons.checkmark_24_regular,
            color: selected ? color : Colors.transparent,
          ),
          selected: selected,
          onSelected: (_) async {},
          visualDensity: const VisualDensity(
            horizontal: VisualDensity.minimumDensity,
          ),
        ),
      ),
    );
  }
}
