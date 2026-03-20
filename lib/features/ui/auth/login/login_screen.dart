import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import '../../../../core/cache/provider/user_provider.dart';
import '../../../../core/model/my_user.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_routes.dart';
import '../../../../core/utils/app_styles.dart';
import '../../../../core/utils/app_validator.dart';
import '../../../../firebase_utils.dart';
import '../../widgets/alert_dialog_utils.dart';
import '../../widgets/custom_elevated_buttom.dart';
import '../../widgets/custom_text_form_field.dart';
import '../widgets/circle_avatar_container.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();
  GlobalKey<FormState> formkey = GlobalKey<FormState>();

  bool hidePassword = true;
  String selectedRole = 'client'; // Default role

  @override
  Widget build(BuildContext context) {
    var userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.offWhiteColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 50.h),
              Image.asset(AppAssets.SOKON),
              SizedBox(height: 50.h),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(67),
                    topLeft: Radius.circular(67),
                  ),
                ),
                child: Form(
                  key: formkey,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 37.w),
                    child: Column(
                      children: [
                        SizedBox(height: 36.h),
                        Center(
                          child: Text("Login", style: AppStyles.bold32Primary),
                        ),
                        SizedBox(height: 48.h),
                        CustomTextFormField(
                          controller: emailCtrl,
                          hintStyle: AppStyles.medium12gray,
                          hintText: "Email",
                          fillColor: AppColors.offWhiteColor,
                          borderSideColor: AppColors.grayColor,
                          validator: (val) => AppValidators.validateEmail(val),
                        ),
                        SizedBox(height: 13.h),

                        /// PASSWORD FIELD
                        CustomTextFormField(
                          controller: passwordCtrl,
                          hintStyle: AppStyles.medium12gray,
                          hintText: "Password",
                          fillColor: AppColors.offWhiteColor,
                          borderSideColor: AppColors.grayColor,
                          obscureText: hidePassword,
                          validator: (val) => AppValidators.validatePassword(val),
                          suffixIconName: IconButton(
                            icon: Icon(
                              hidePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() => hidePassword = !hidePassword);
                            },
                          ),
                        ),
                        SizedBox(height: 15.h),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(
                                context,
                              ).pushNamed(AppRoutes.forgetPasswordRoute);
                            },
                            child: Text(
                              "Forgot password ?",
                              style: AppStyles.semiBold14Primary,
                            ),
                          ),
                        ),
                        SizedBox(height: 27.h),
                        CustomElevatedButtom(
                          onPressed: () {

                          },
                          text: "Login",
                          width: 200,
                          backgroundColorElevated: AppColors.primaryColor,
                          textStyle: AppStyles.semiBold20White,
                          borderColor: Colors.transparent,
                          customPadding: 19.h,
                        ),
                        SizedBox(height: 30.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            InkWell(
                              onTap: () {
                                signInWithGoogle(userProvider);
                              },
                              child: CircleAvatarContainer(
                                image: AppAssets.googleIcon,
                              ),
                            ),
                            InkWell(
                              onTap: () {},
                              child: CircleAvatarContainer(
                                image: AppAssets.appleIcon,
                              ),
                            ),
                            InkWell(
                              onTap: () {},
                              child: CircleAvatarContainer(
                                image: AppAssets.facebookIcon,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 30.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account?",
                              style: AppStyles.regular14gray,
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(
                                  context,
                                ).pushReplacementNamed(AppRoutes.registerRoute);
                              },
                              child: Text(
                                "Sign Up",
                                style: AppStyles.semiBold14Primary,
                              ),
                            ),
                            SizedBox(height: 50.h),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showRoleSelectionDialog(MyUser user, UserProvider userProvider) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        String role = 'client';
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Select Role"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<String>(
                    title: const Text("Client"),
                    value: 'client',
                    groupValue: role,
                    onChanged: (value) => setState(() => role = value!),
                  ),
                  RadioListTile<String>(
                    title: const Text("Owner"),
                    value: 'owner',
                    groupValue: role,
                    onChanged: (value) => setState(() => role = value!),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    user.role = role;
                    await FireBaseUtils.addUserToFirestore(user);
                    userProvider.updateUser(user);

                      Navigator.pop(context);
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        AppRoutes.homeScreenRoute,
                            (route) => false,
                      );

                  },
                  child: const Text("Confirm"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> signInWithGoogle(UserProvider userProvider) async {
    try {
      final GoogleSignIn signIn = GoogleSignIn.instance;
      await signIn.initialize(
        clientId: dotenv.env['server_client_id'],
      );

      final GoogleSignInAccount? googleUser = await GoogleSignIn.instance.authenticate();
      if (googleUser == null) {
        return;
      }

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);

      var firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        var user = await FireBaseUtils.readUserFromFireStore(firebaseUser.uid);
        if (user == null || user.role == null) {
          MyUser newUser = MyUser(
            id: firebaseUser.uid,
            name: firebaseUser.displayName ?? "",
            email: firebaseUser.email ?? "",
            role: null,
          );

            showRoleSelectionDialog(newUser, userProvider);

        } else {
          // Existing user with role
          userProvider.updateUser(user);

            Navigator.of(context).pushNamedAndRemoveUntil(
              AppRoutes.homeScreenRoute,
                  (route) => false,
            );

        }
      }
    } catch (e) {

        AlertDialogUtils.showMessage(
          context: context,
          msg: e.toString(),
          title: "Google Sign-In Error",
        );

    }
  }
}
