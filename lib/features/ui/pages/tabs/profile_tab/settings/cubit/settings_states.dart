import 'dart:io';
import '../../../../../../../core/model/RegisterResponse.dart';

abstract class SettingsState {}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsImagePicked extends SettingsState {
  final File image;
  SettingsImagePicked(this.image);
}

class SettingsSuccess extends SettingsState {
  final RegisterUser user;
  SettingsSuccess(this.user);
}

class SettingsPhoneVerified extends SettingsState {
  final RegisterUser user;
  SettingsPhoneVerified(this.user);
}

class SettingsError extends SettingsState {
  final String message;
  SettingsError(this.message);
}
