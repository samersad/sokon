import 'dart:io';
import '../../../../../../../core/model/my_user.dart';

abstract class SettingsState {}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsImagePicked extends SettingsState {
  final File image;
  SettingsImagePicked(this.image);
}

class SettingsSuccess extends SettingsState {
  final MyUser user;
  SettingsSuccess(this.user);
}

class SettingsError extends SettingsState {
  final String message;
  SettingsError(this.message);
}
