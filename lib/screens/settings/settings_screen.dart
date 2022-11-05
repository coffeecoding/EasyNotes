import 'dart:ui';

import 'package:easynotes/cubits/cubits.dart';
import 'package:easynotes/screens/common/inline_button.dart';
import 'package:easynotes/screens/common/input_label.dart';
import 'package:easynotes/screens/common/progress_indicators.dart';
import 'package:easynotes/screens/common/section_header.dart';
import 'package:easynotes/screens/common/toolbar_button.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PreferenceCubit, PreferenceState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
              titleSpacing: 8,
              elevation: 0,
              backgroundColor: Colors.transparent,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child:
                    Container(height: 1, color: Theme.of(context).dividerColor),
              ),
              title: const Text('Settings')),
          body: SingleChildScrollView(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (state.message.isNotEmpty) Text(state.message),
              const SectionHeader(text: 'Synchronization'),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: InputLabel(
                    text:
                        'If enabled, backs up your end-to-end-encrypted notes to the cloud so you can access them from anywhere.'),
              ),
              SwitchListTile(
                  title: const Text('Synchronize notes'),
                  value: state.enableSync,
                  onChanged: (newVal) async {
                    context.read<PreferenceCubit>().updateSync(newVal);
                  }),
              const SectionHeader(text: 'Appearance'),
              SwitchListTile(
                  title: const Text('Dark mode'),
                  value: state.useDarkMode,
                  onChanged: (newVal) async {
                    context.read<PreferenceCubit>().updateUseDarkMode(newVal);
                  }),
              /*_buildTitledButtons(context, <Widget>[
                  for (ThemeMode tm in ThemeMode.values) ThemeModeButton(tm)
                ])*/
              const SectionHeader(text: 'Profile'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Builder(builder: (context) {
                  final prefsCubit = context.read<PreferenceCubit>();
                  return PasswordSection(prefCubit: prefsCubit);
                }),
              ),
              const SectionHeader(text: 'About'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    InputLabel(text: 'Made by YSCodes'),
                    InputLabel(text: 'Twitter @YSCodes'),
                    InputLabel(text: 'Github CoffeeCoding'),
                    InputLabel(text: 'This app is free and ad-free'),
                  ],
                ),
              )
            ]),
          ),
        );
      },
    );
  }

  Widget _buildTitledButtons(BuildContext context, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      child: Row(children: children),
    );
    ;
  }
}

class PasswordSection extends StatefulWidget {
  PasswordSection({required this.prefCubit, super.key})
      : pwCtr = TextEditingController(text: '');

  final PreferenceCubit prefCubit;
  final TextEditingController pwCtr;

  @override
  State<PasswordSection> createState() => _PasswordSectionState();
}

class _PasswordSectionState extends State<PasswordSection> {
  bool isEditing = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
                child: Text(
              'Password',
              style: TextStyle(fontSize: 16),
            )),
            if (isEditing)
              Expanded(
                  child: FutureBuilder(
                      future: widget.prefCubit.password,
                      builder: ((context, snapshot) => snapshot.hasData
                          ? Builder(builder: (context) {
                              widget.pwCtr.text = snapshot.data as String;
                              return TextField(
                                  selectionHeightStyle: BoxHeightStyle.tight,
                                  controller: widget.pwCtr);
                            })
                          : Container()))),
            if (!isEditing)
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: TextField(
                  textAlign: TextAlign.right,
                  decoration: null,
                  controller: TextEditingController(text: 'blablabla'),
                  enabled: false,
                  obscureText: true,
                  style:
                      TextStyle(decoration: null, color: Colors.grey.shade600),
                ),
              ))
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (isEditing)
              ToolbarButton(
                  small: true,
                  iconData: FluentIcons.dismiss_16_regular,
                  onPressed: () => setState(() {
                        isEditing = false;
                      }),
                  title: 'Cancel'),
            if (isEditing)
              ToolbarButton(
                  small: true,
                  iconData: FluentIcons.save_20_regular,
                  onPressed: () => setState(() {
                        isEditing = false;
                      }),
                  title: 'Save'),
            if (!isEditing)
              ToolbarButton(
                  small: true,
                  iconData: FluentIcons.edit_20_regular,
                  onPressed: () => setState(() {
                        isEditing = true;
                      }),
                  title: 'Change password')
          ],
        )
      ],
    );
  }
}

class ThemeModeButton extends StatelessWidget {
  const ThemeModeButton(this.mode, {super.key});

  final ThemeMode mode;

  @override
  Widget build(BuildContext context) {
    const ThemeMode selectedMode = ThemeMode.system;
    final bool selected = mode == selectedMode;
    final Color color = Colors.transparent;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChipTheme(
        data: ChipThemeData.fromDefaults(
          brightness: ThemeData.estimateBrightnessForColor(color),
          secondaryColor: color,
          labelStyle: const TextStyle(),
        ).copyWith(
          backgroundColor: color,
          secondaryLabelStyle:
              TextStyle(color: Theme.of(context).colorScheme.primary),
          side: selected
              ? BorderSide(color: Theme.of(context).colorScheme.primary)
              : const BorderSide(color: Colors.transparent),
        ),
        child: ChoiceChip(
          onSelected: (_) {},
          selected: selected,
          label: const Text('Theme'),
        ),
      ),
    );
  }
}
