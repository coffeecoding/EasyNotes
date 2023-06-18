// Functions to build debug messages and
enum ErrorType { network, client }

class MsgWrapper {
  final String msg;
  final String friendlyMsg;
  MsgWrapper(this.msg, this.friendlyMsg);
}

String _buildErrorMsg(ErrorType type, String functionName, List<dynamic> params,
    String? sourceErrorMessage) {
  return '${type.toString().toUpperCase()} error in $functionName($params): $sourceErrorMessage';
}

MsgWrapper buildErrorMsgs(ErrorType type, String functionName,
    List<dynamic> params, String? sourceErrorMessage) {
  return MsgWrapper(
      _buildErrorMsg(type, functionName, params, sourceErrorMessage),
      FriendlyMsgs.byType[type]!);
}

class FriendlyMsgs {
  static const String networkError =
      'Network error! Please verify your Internet connection.';
  static const String clientError =
      'Something went wrong. Please update and restart the app.';

  static Map<ErrorType, String> byType = <ErrorType, String>{
    ErrorType.network: networkError,
    ErrorType.client: clientError
  };
}
