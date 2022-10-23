import 'package:easynotes/cubits/cubits.dart';
import 'package:easynotes/cubits/topic/topic_cubit.dart';
import 'package:easynotes/screens/common/input_label.dart';
import 'package:easynotes/screens/common/title_textfield.dart';
import 'package:easynotes/screens/common/toolbar_button.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
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
            baseOffset: state.topicCubit?.title == null
                ? 0
                : state.topicCubit!.title.length,
            extentOffset: 0);
        return Container(
          height: 400,
          width: 400,
          child: Scaffold(
            appBar: AppBar(
                titleSpacing: 0,
                leading: ToolbarButton(
                    iconData: FluentIcons.arrow_left_16_regular,
                    title: '',
                    enabledColor: Colors.white,
                    onPressed: () => Navigator.of(context).pop(false)),
                title: Text(titleText),
                actions: [
                  ToolbarButton(
                      iconData: FluentIcons.delete_20_regular,
                      title: 'Trash',
                      onPressed: () {}),
                  ToolbarButton(
                      iconData: FluentIcons.save_20_regular,
                      title: 'Save',
                      onPressed: () {}),
                ]),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const InputLabel(text: 'Title:'),
                  TitleTextfield(focusNode: titleFN),
                  const SizedBox(height: 32),
                  const InputLabel(text: 'Color:'),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
