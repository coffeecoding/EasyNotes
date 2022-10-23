import 'package:flutter/material.dart';

class TitleTextfield extends StatelessWidget {
  const TitleTextfield(
      {super.key,
      this.onChanged,
      this.onEditingComplete,
      this.onTap,
      this.focusNode,
      this.controller});

  final Function(String)? onChanged;
  final Function()? onEditingComplete;
  final Function()? onTap;
  final FocusNode? focusNode;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
        cursorWidth: 1,
        decoration: InputDecoration(
            hoverColor: Colors.green,
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                    width: 0, color: Theme.of(context).primaryColor)),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                    width: 1.0 /
                        MediaQuery.of(context)
                            .devicePixelRatio, // this is how to generally achieve 1 pixel width in Flutter
                    color: Theme.of(context).dividerColor))),
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w100),
        onChanged: onChanged,
        onEditingComplete: onEditingComplete,
        toolbarOptions: const ToolbarOptions(
            paste: true, copy: true, selectAll: true, cut: true),
        onTap: onTap,
        focusNode: focusNode,
        controller: controller);
  }
}
