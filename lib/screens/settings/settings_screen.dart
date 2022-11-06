import 'dart:ui';

import 'package:easynotes/blocs/auth/auth_bloc.dart';
import 'package:easynotes/config/locator.dart';
import 'package:easynotes/cubits/cubits.dart';
import 'package:easynotes/repositories/preference_repository.dart';
import 'package:easynotes/screens/common/inline_button.dart';
import 'package:easynotes/screens/common/input_label.dart';
import 'package:easynotes/screens/common/progress_indicators.dart';
import 'package:easynotes/screens/common/section_header.dart';
import 'package:easynotes/screens/common/toolbar_button.dart';
import 'package:easynotes/utils/email_util.dart';
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
              if (state.message.isNotEmpty)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    state.message,
                    style: const TextStyle(color: Colors.amber),
                  ),
                ),
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
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    PasswordSection(),
                    const SizedBox(height: 10),
                    EmailSection(),
                    const SizedBox(height: 10),
                    const LogoutSection(),
                  ],
                ),
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

class LogoutSection extends StatelessWidget {
  const LogoutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final prefCubit = context.read<PreferenceCubit>();
    final authBloc = context.read<AuthBloc>();
    final prefRepo = locator.get<PreferenceRepository>();
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FutureBuilder(
                future: prefRepo.username,
                builder: (context, snapshot) {
                  return snapshot.hasData
                      ? Text(
                          'Signed in as ${snapshot.data}',
                          style: const TextStyle(fontSize: 16),
                        )
                      : const Text(
                          'Signed in as ...',
                          style: TextStyle(fontSize: 16),
                        );
                }),
            ElevatedButton(onPressed: () {}, child: const Text('Sign out'))
          ],
        )
      ],
    );
  }
}

class PasswordSection extends StatefulWidget {
  PasswordSection({super.key}) : pwCtr = TextEditingController(text: '');

  final TextEditingController pwCtr;

  @override
  State<PasswordSection> createState() => _PasswordSectionState();
}

class _PasswordSectionState extends State<PasswordSection> {
  bool isEditing = false;
  bool isSaving = false;

  @override
  Widget build(BuildContext context) {
    final prefCubit = context.read<PreferenceCubit>();
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
                      future: prefCubit.password,
                      builder: ((context, snapshot) => snapshot.hasData
                          ? Builder(builder: (context) {
                              widget.pwCtr.text = snapshot.data as String;
                              FocusNode pwFN = FocusNode();
                              pwFN.requestFocus();
                              return TextField(
                                  focusNode: pwFN,
                                  textAlign: TextAlign.right,
                                  decoration: null,
                                  selectionHeightStyle: BoxHeightStyle.tight,
                                  controller: widget.pwCtr);
                            })
                          : Container()))),
            if (!isEditing)
              Expanded(
                child: TextField(
                  textAlign: TextAlign.right,
                  selectionHeightStyle: BoxHeightStyle.tight,
                  controller: TextEditingController(text: 'blablabla'),
                  decoration: null,
                  enabled: false,
                  obscureText: true,
                  style:
                      TextStyle(decoration: null, color: Colors.grey.shade600),
                ),
              )
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
              isSaving
                  ? const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: InlineCircularProgressIndicator(),
                    )
                  : ToolbarButton(
                      small: true,
                      iconData: FluentIcons.save_20_regular,
                      onPressed: () async {
                        if (widget.pwCtr.text.isEmpty) {
                          AlertDialog dlg = AlertDialog(
                              actionsPadding: const EdgeInsets.all(16),
                              actionsAlignment: MainAxisAlignment.end,
                              actions: [
                                Expanded(child: Container()),
                                ToolbarButton(
                                    iconData: FluentIcons.dismiss_16_regular,
                                    title: 'OK',
                                    onPressed: () =>
                                        Navigator.of(context).pop())
                              ],
                              contentPadding: const EdgeInsets.all(16),
                              content: const Text('Password cannot be empty'));
                          await showDialog(
                              context: context, builder: (_) => dlg);
                          return;
                        }
                        setState(() {
                          isSaving = true;
                        });
                        bool success = await prefCubit.updateUser(
                            newPassword: widget.pwCtr.text);
                        setState(() {
                          if (success) {
                            isEditing = false;
                          }
                          isSaving = false;
                        });
                      },
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

class EmailSection extends StatefulWidget {
  EmailSection({super.key}) : pwCtr = TextEditingController(text: '');

  final TextEditingController pwCtr;

  @override
  State<EmailSection> createState() => _EmailSectionState();
}

class _EmailSectionState extends State<EmailSection> {
  bool isEditing = false;
  bool isSaving = false;

  @override
  Widget build(BuildContext context) {
    final prefCubit = context.read<PreferenceCubit>();
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
                child: Text(
              'Email Address',
              style: TextStyle(fontSize: 16),
            )),
            Expanded(
                child: FutureBuilder(
                    future: prefCubit.email,
                    builder: ((context, snapshot) => snapshot.hasData
                        ? Builder(builder: (context) {
                            widget.pwCtr.text = snapshot.data as String;
                            FocusNode emailFN = FocusNode();
                            emailFN.requestFocus();
                            return TextField(
                                decoration: null,
                                focusNode: emailFN,
                                style: TextStyle(
                                    color: isEditing
                                        ? null
                                        : Colors.grey.shade600),
                                enabled: isEditing,
                                textAlign: TextAlign.right,
                                selectionHeightStyle: BoxHeightStyle.tight,
                                controller: widget.pwCtr);
                          })
                        : Container()))),
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
              isSaving
                  ? const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: InlineCircularProgressIndicator(),
                    )
                  : ToolbarButton(
                      small: true,
                      iconData: FluentIcons.save_20_regular,
                      onPressed: () async {
                        if (!isValidEmail(widget.pwCtr.text)) {
                          AlertDialog dlg = AlertDialog(
                              actionsPadding: const EdgeInsets.all(16),
                              actionsAlignment: MainAxisAlignment.end,
                              actions: [
                                Expanded(child: Container()),
                                ToolbarButton(
                                    iconData: FluentIcons.dismiss_16_regular,
                                    title: 'OK',
                                    onPressed: () =>
                                        Navigator.of(context).pop())
                              ],
                              contentPadding: const EdgeInsets.all(16),
                              content: const Text('Invalid email address.'));
                          await showDialog(
                              context: context, builder: (_) => dlg);
                          return;
                        }
                        setState(() {
                          isSaving = true;
                        });
                        bool success = await prefCubit.updateUser(
                            newEmail: widget.pwCtr.text);
                        setState(() {
                          if (success) {
                            isEditing = false;
                          }
                          isSaving = false;
                        });
                      },
                      title: 'Save'),
            if (!isEditing)
              ToolbarButton(
                  small: true,
                  iconData: FluentIcons.edit_20_regular,
                  onPressed: () => setState(() {
                        isEditing = true;
                      }),
                  title: 'Change email')
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
