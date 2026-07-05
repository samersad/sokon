import 'package:sokon/core/model/RegisterResponse.dart';

class PhoneVerificationUtils {
  PhoneVerificationUtils._();

  static String digitsOnly(String? value) {
    return (value ?? '').replaceAll(RegExp(r'\D'), '');
  }

  static String displayLocal(String? value) {
    var digits = digitsOnly(value);
    if (digits.startsWith('002')) {
      digits = digits.substring(3);
    }
    if (digits.startsWith('2') && digits.length == 12) {
      digits = digits.substring(1);
    }
    return digits;
  }

  static bool isValidEgyptianMobile(String? value) {
    final phone = displayLocal(value);
    return RegExp(r'^01[0125]\d{8}$').hasMatch(phone);
  }

  static bool isSamePhone(String? first, String? second) {
    return displayLocal(first) == displayLocal(second);
  }

  static bool canRent(RegisterUser? user) {
    return user?.phoneVerified == true &&
        isValidEgyptianMobile(user?.phoneNumber);
  }
}
