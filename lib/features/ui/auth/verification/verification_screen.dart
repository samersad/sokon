import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pinput/pinput.dart';
import 'package:sokon/core/di/di.dart';
import 'package:sokon/core/utils/app_routes.dart';
import 'package:sokon/features/ui/auth/forget_password/cubit/forget_password_states.dart';
import 'package:sokon/features/ui/auth/forget_password/cubit/forget_password_view_model.dart';
import 'package:sokon/features/ui/widgets/alert_dialog_utils.dart';

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
  final ForgetPasswordViewModel viewModel = getIt<ForgetPasswordViewModel>();

  late final PinTheme defaultPinTheme;
  late final PinTheme focusedPinTheme;
  late final PinTheme submittedPinTheme;

  static const int _startSeconds = 60;
  int _secondsLeft = _startSeconds;
  Timer? _timer;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  String? email;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    email = ModalRoute.of(context)!.settings.arguments as String?;
    if (email != null) {
      viewModel.userEmail = email;
    }
  }

  @override
  void initState() {
    super.initState();

    defaultPinTheme = PinTheme(
      width: 48.w,
      height: 48.w,
      textStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryColor,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.verificationBorder,
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
        color: AppColors.verificationField,
      ),
    );

    _startTimer();

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

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

  @override
  void dispose() {
    _timer?.cancel();
    _shakeController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocProvider.value(
      value: viewModel,
      child: BlocListener<ForgetPasswordViewModel, ForgetPasswordState>(
        listener: (context, state) {
          if (state is ForgetPasswordLoading) {
            AlertDialogUtils.showLoading(context: context, msg: "Verifying OTP...");
          } else if (state is ForgetPasswordError) {
            AlertDialogUtils.hideLoading(context: context);
            AlertDialogUtils.showMessage(context: context, msg: state.message, title: "Error");
            _shakeController.forward(from: 0);
          } else if (state is OTPSuccess) {
            AlertDialogUtils.hideLoading(context: context);
            Navigator.of(context).pushNamed(AppRoutes.forgetPassword2Route);
          }
        },
        child: Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
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
                            style: theme.textTheme.headlineMedium,
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            "* We will send you a message to reset your password",
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Enter the 6-digit code sent to:",
                        style: theme.textTheme.bodyMedium,
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        email ?? "",
                        style: theme.textTheme.labelMedium,
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
                          length: 6,
                          controller: _pinController,
                          defaultPinTheme: defaultPinTheme,
                          focusedPinTheme: focusedPinTheme,
                          submittedPinTheme: submittedPinTheme,
                          separatorBuilder: (index) => SizedBox(width: 8.w),
                          onCompleted: (pin) => viewModel.verifyOTP(pin),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      _secondsLeft > 0
                          ? Text(
                            "Resend code in $_secondsLeft s",
                              style: theme.textTheme.bodyMedium,
                            )
                          : GestureDetector(
                              onTap: () {
                                if (email != null) viewModel.sendOTP(email!);
                                _startTimer();
                              },
                              child: Text(
                                "Resend Code",
                                style: theme.textTheme.displaySmall,
                              ),
                            ),
                      SizedBox(height: 40.h),
                      CustomElevatedButtom(
                        onPressed: () {
                          if (_pinController.text.length == 6) {
                            viewModel.verifyOTP(_pinController.text);
                          }
                        },
                        text: "Submit",
                        width: 336.w,
                        borderRadius: 30.r,
                        backgroundColorElevated: theme.primaryColor,
                        textStyle: theme.textTheme.titleLarge,
                        borderColor: AppColors.transparentColor,
                        customPadding: 16.h,
                      ),
                      SizedBox(height: 30.h),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
