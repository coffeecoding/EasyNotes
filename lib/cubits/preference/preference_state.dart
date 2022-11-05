part of 'preference_cubit.dart';

class PreferenceState extends Equatable {
  const PreferenceState._(
      {this.enableSync = true,
      this.useDarkMode = true,
      this.isEditingEmail = false,
      this.isEditingPassword = false,
      this.message = ''});

  const PreferenceState.init() : this._();

  PreferenceState.copyWith({
    required PreferenceState prev,
    bool? enableSync,
    bool? useDarkMode,
    bool? isEditingPassword,
    bool? isEditingEmail,
    String? message,
  }) : this._(
          enableSync: enableSync ?? prev.enableSync,
          useDarkMode: useDarkMode ?? prev.useDarkMode,
          isEditingEmail: isEditingEmail ?? prev.isEditingEmail,
          isEditingPassword: isEditingPassword ?? prev.isEditingPassword,
          message: message ?? '',
        );

  final bool enableSync;
  final bool useDarkMode;
  final bool isEditingPassword;
  final bool isEditingEmail;
  final String message;

  @override
  List<Object> get props =>
      [enableSync, useDarkMode, isEditingPassword, isEditingEmail, message];
}
