import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../../../../core/cache/cubit_manger/user_view_model.dart';
import '../../../../../../../core/model/RegisterResponse.dart';
import '../../../../../../../core/utils/phone_verification_utils.dart';
import '../../../../../../../data/repository/auth/repository/auth_repository.dart';
import 'settings_states.dart';

@injectable
class SettingsViewModel extends Cubit<SettingsState> {
  final UserViewModel userViewModel;
  final AuthRepository authRepository;

  SettingsViewModel(this.userViewModel, this.authRepository)
    : super(SettingsInitial());

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
      await Permission.photos.request();
    }
  }

  Future<void> saveChanges(
    String name,
    String phoneNumber,
    String? college, {
    bool markPhoneVerified = false,
  }) async {
    final user = userViewModel.user;
    if (user == null) return;

    emit(SettingsLoading());
    try {
      final updatedUser = await authRepository.updateProfileWithBackend(
        user,
        name,
        phoneNumber,
        college,
        user.gender,
        profileImage,
      );
      if (markPhoneVerified &&
          PhoneVerificationUtils.isValidEgyptianMobile(phoneNumber)) {
        updatedUser.phoneVerified = true;
        userViewModel.updateUser(updatedUser);
        await userViewModel.updatePhoneVerification(
          verified: true,
          phoneNumber: phoneNumber,
        );
        emit(SettingsPhoneVerified(updatedUser));
        return;
      }

      userViewModel.updateUser(updatedUser);
      emit(SettingsSuccess(updatedUser));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> requestPhoneVerificationOTP(
    String phoneNumber, {
    String channel = 'sms',
  }) {
    return authRepository.requestPhoneVerificationOTP(
      phoneNumber,
      channel: channel,
    );
  }

  Future<RegisterUser> verifyPhoneOTP(String phoneNumber, String otp) async {
    final user = await authRepository.verifyPhoneOTP(phoneNumber, otp);
    userViewModel.updateUser(user);
    emit(SettingsPhoneVerified(user));
    return user;
  }
}
