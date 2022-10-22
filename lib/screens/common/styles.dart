import 'package:flutter/material.dart';

class ENButtonTextStyle extends TextStyle {
  const ENButtonTextStyle() : super(fontWeight: FontWeight.w600);
}

class ENPrimaryButtonStyle extends ButtonStyle {
  const ENPrimaryButtonStyle()
      : super(
            textStyle: const MaterialStatePropertyAll(ENButtonTextStyle()),
            minimumSize: const MaterialStatePropertyAll(Size(144, 40)));
}
