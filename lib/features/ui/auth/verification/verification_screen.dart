import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pinput/pinput.dart';
import 'package:sokon/core/utils/app_routes.dart';

import '../../../../core/utils/app_assets.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_styles.dart';
import '../../widgets/custom_elevated_buttom.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _pinController = TextEditingController();

  late final PinTheme defaultPinTheme;
  late final PinTheme focusedPinTheme;
  late final PinTheme submittedPinTheme;

  static const int _startSeconds = 60;
  int _secondsLeft = _startSeconds;
  Timer? _timer;


  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();

    defaultPinTheme = PinTheme(
      width: 52.w,
      height: 52.w,
      textStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Color(0xFF0A3D62),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFB9C7D9),
          width: 1.2,
        ),
      ),
    );

    focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(
        color: AppColors.primaryColor,
        width: 1.5,
      ),
    );

    submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: const Color(0xFFEAEFF3),
      ),
    );

    _startTimer();

    // ---------- SHAKE ----------
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  // ================= TIMER LOGIC =================
  void _startTimer() {
    _timer?.cancel();
    _secondsLeft = _startSeconds;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft == 0) {
        timer.cancel();
      } else {
        setState(() {
          _secondsLeft--;
        });
      }
    });
  }

  // ================= VALIDATION =================
  void _validatePin(String pin) {
    if (pin == '2222') {
      debugPrint('OTP صحيح ✅');
      // Navigate to next screen
    } else {
      _shakeController.forward(from: 0);
      _pinController.clear();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _shakeController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Image.asset(AppAssets.verificationBg),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 50.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Verification",
                        style: AppStyles.regular30primary,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        "* We will send you a message to set or reset your new password",
                        style: AppStyles.medium12gray,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.w),
              child: Column(
                children: [
                  Text(
                    "We will send you one time password this email address.",
                    style: AppStyles.medium12gray,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    "(example123@gmail.com)",
                    style: AppStyles.semiBold15black,
                  ),
                  SizedBox(height: 24.h),

                  AnimatedBuilder(
                    animation: _shakeAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(_shakeAnimation.value, 0),
                        child: child,
                      );
                    },
                    child: Pinput(
                      length: 4,
                      controller: _pinController,
                      defaultPinTheme: defaultPinTheme,
                      focusedPinTheme: focusedPinTheme,
                      submittedPinTheme: submittedPinTheme,
                      separatorBuilder: (index) =>
                          SizedBox(width: 12.w),

                      // 🔥 AUTO SUBMIT
                      onCompleted: _validatePin,
                    ),
                  ),

                  SizedBox(height: 20.h),

                  _secondsLeft > 0
                      ? Text(
                    "Resend code in $_secondsLeft s",
                    style: AppStyles.medium12gray,
                  )
                      : GestureDetector(
                    onTap: () {
                      debugPrint('Resend OTP');
                      _startTimer();
                    },
                    child: Text(
                      "Resend Code",
                      style: AppStyles.semiBold14Primary,
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // ================= SUBMIT =================
                  CustomElevatedButtom(
                    onPressed: () {
                      _validatePin(_pinController.text);
                      Navigator.of(context).pushNamed(AppRoutes.forgetPassword2Route);
                    },
                    text: "Submit",
                    width: 336.w,
                    borderRadius: 30.r,
                    backgroundColorElevated:
                    AppColors.primaryColor,
                    textStyle: AppStyles.semiBold20White,
                    borderColor: AppColors.blackColor,
                    customPadding: 16.h,
                  ),

                  SizedBox(height: 30.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
