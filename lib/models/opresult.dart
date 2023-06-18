import 'dart:core';

import 'package:easynotes/config/messages.dart';

class OPResult<T> {
  final T? data;
  final String? msg;
  final String? friendlyMsg;

  bool get hasData => data != null;

  OPResult(this.data, {this.msg, this.friendlyMsg});

  OPResult.err(MsgWrapper msgs, {this.data})
      : msg = msgs.msg,
        friendlyMsg = msgs.friendlyMsg;

  @override
  String toString() => 'OPRESULT: $msg';
}
