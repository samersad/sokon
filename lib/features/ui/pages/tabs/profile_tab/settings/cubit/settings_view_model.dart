import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../../../../cloudinary_service.dart';
import '../../../../../../../core/cache/cubit_manger/user_view_model.dart';
import '../../../../../../../firebase_utils.dart';
import 'settings_states.dart';

class SettingsViewModel extends Cubit<SettingsState> {
  final UserViewModel userViewModel;
  SettingsViewModel(this.userViewModel) : super(SettingsInitial());

  File? profileImage;

  Future<void> pickImage(ImageSource source) async {
    await _requestPermission(source);
    final ImagePicker imagePicker = ImagePicker();
    final XFile? pickedFile = await imagePicker.pickImage(source: source);

    if (pickedFile != null) {
      profileImage = File(pickedFile.path);
      emit(SettingsImagePicked(profileImage!));
    }
  }

  Future<void> _requestPermission(ImageSource source) async {
    if (source == ImageSource.camera) {
      await Permission.camera.request();
    } else {
      await Permission.storage.request();
    }
  }

  Future<void> saveChanges(String name) async {
    final user = userViewModel.user;
    if (user == null) return;

    emit(SettingsLoading());
    try {
      String? photoUrl = user.photoUrl;
      if (profileImage != null) {
        photoUrl = await CloudinaryService.uploadImage(profileImage!);
      }

      user.name = name;
      user.photoUrl = photoUrl;

      await FireBaseUtils.addUserToFirestore(user);
      userViewModel.updateUser(user);
      emit(SettingsSuccess(user));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }
}
