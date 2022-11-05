import 'package:easynotes/screens/common/input_label.dart';
import 'package:easynotes/screens/common/section_header.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 500,
      width: 400,
      child: Scaffold(
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
            const SectionHeader(text: 'Synchronization'),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: InputLabel(
                  text:
                      'If enabled, backs up your end-to-end-encrypted notes to the cloud so you can access them from anywhere.'),
            ),
            SwitchListTile(
                title: const Text('Synchronize notes'),
                value: false,
                onChanged: (_) {}),
            const SectionHeader(text: 'Appearance'),
            SwitchListTile(
                title: const Text('Dark mode'),
                value: false,
                onChanged: (_) {}),
            /*_buildTitledButtons(context, <Widget>[
              for (ThemeMode tm in ThemeMode.values) ThemeModeButton(tm)
            ])*/
            const SectionHeader(text: 'Profile'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: const [
                  Expanded(
                      child: Text(
                    'Change password',
                    style: TextStyle(fontSize: 16),
                  )),
                  Expanded(child: TextField()),
                ],
              ),
            )
          ]),
        ),
      ),
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
