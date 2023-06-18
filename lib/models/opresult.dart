import 'dart:core';

import 'package:easynotes/config/messages.dart';

class OPResult<T> {
  final T? result;
  final String? msg;
  final String? friendlyMsg;

  bool get hasResult => result != null;

  OPResult(this.result, {this.msg, this.friendlyMsg});

  OPResult.err(MsgWrapper msgs, {this.result})
      : msg = msgs.msg,
        friendlyMsg = msgs.friendlyMsg;
}
