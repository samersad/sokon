import 'package:sokon/l10n/app_localizations.dart';
import 'package:sokon/core/utils/phone_verification_utils.dart';

class AppValidators {
  AppValidators._();

  static String? validateEmail(String? val, AppLocalizations l10n) {
    final RegExp emailRegex = RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+$",
    );

    if (val == null || val.trim().isEmpty) {
      return l10n.fieldRequired;
    } else if (!emailRegex.hasMatch(val.trim())) {
      return l10n.enterValidEmail;
    } else {
      return null;
    }
  }

  static String? validatePassword(String? val, AppLocalizations l10n) {
    // Fixed regex: removed extra spaces and improved lookahead groups
    RegExp passwordRegex = RegExp(r'^(?=.*[a-zA-Z])(?=.*[0-9])');
    if (val == null || val.isEmpty) {
      return l10n.fieldRequired;
    } else if (val.length < 8 || !passwordRegex.hasMatch(val)) {
      return l10n.passwordValidation;
    } else {
      return null;
    }
  }

  static String? validateConfirmPassword(
    String? val,
    String? password,
    AppLocalizations l10n,
  ) {
    if (val == null || val.isEmpty) {
      return l10n.fieldRequired;
    } else if (val != password) {
      return l10n.passwordsNotMatching;
    } else {
      return null;
    }
  }

  static String? validateUsername(String? val, AppLocalizations l10n) {
    RegExp usernameRegex = RegExp(r'^[a-zA-Z0-9, . -]+$');

    if (val == null || val.isEmpty) {
      return l10n.fieldRequired;
    } else if (!usernameRegex.hasMatch(val)) {
      return l10n.enterValidUsername;
    } else {
      return null;
    }
  }

  static String? validateFullName(String? val, AppLocalizations l10n) {
    if (val == null || val.isEmpty) {
      return l10n.fieldRequired;
    } else {
      return null;
    }
  }

  static String? validatePhoneNumber(String? val, AppLocalizations l10n) {
    final localPhone = PhoneVerificationUtils.displayLocal(val);
    if (val == null || val.trim().isEmpty) {
      return l10n.fieldRequired;
    } else if (localPhone.isEmpty || int.tryParse(localPhone) == null) {
      return l10n.enterNumbersOnly;
    } else if (!PhoneVerificationUtils.isValidEgyptianMobile(localPhone)) {
      return l10n.phoneValidation;
    } else {
      return null;
    }
  }
}
