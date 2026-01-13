import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:sokon/features/ui/auth/forget_password/forget_password_screen.dart';
import 'package:sokon/features/ui/auth/forget_password/forget_password_screen2.dart';
import 'package:sokon/features/ui/auth/register/register_screen.dart';
import 'package:sokon/features/ui/auth/verification/verification_screen.dart';
import 'package:sokon/features/ui/pages/home_screen/home_screen.dart';

import 'core/cache/provider/location_provider.dart';
import 'core/utils/app_routes.dart';
import 'features/ui/auth/login/login_screen.dart';
import 'features/ui/pages/add_apartment/add_apartment.dart';

Future<void> main() async {
WidgetsFlutterBinding.ensureInitialized();

  runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) =>LocationProvider() ,)

      ],

      child: const MyApp()));}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize:  Size( 393, 852),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child){
          return MaterialApp(
             debugShowCheckedModeBanner: false,
            initialRoute: AppRoutes.loginRoute,
              routes: {
                AppRoutes.homeScreenRoute: (context) => HomeScreen(),
                AppRoutes.loginRoute: (context) => LoginScreen(),
                AppRoutes.registerRoute: (context) => RegisterScreen(),
                AppRoutes.forgetPasswordRoute: (context) => ForgetPasswordScreen(),
                AppRoutes.verificationRoute: (context) => VerificationScreen(),
                AppRoutes.forgetPassword2Route: (context) => ForgetPasswordScreen2(),
                AppRoutes.addApartmentRoute: (context) => AddApartment(),

              },
              theme: ThemeData.light()
          );
        }
    );
  }


}
