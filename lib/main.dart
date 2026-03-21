import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:sokon/core/cache/provider/user_provider.dart';
import 'package:sokon/features/ui/auth/forget_password/forget_password_screen.dart';
import 'package:sokon/features/ui/auth/forget_password/forget_password_screen2.dart';
import 'package:sokon/features/ui/auth/register/register_screen.dart';
import 'package:sokon/features/ui/auth/verification/verification_screen.dart';
import 'package:sokon/features/ui/location_picker/location_picker.dart';
import 'package:sokon/features/ui/pages/booking_screen/booking_screen.dart';
import 'package:sokon/features/ui/pages/home_screen/home_screen.dart';
import 'package:sokon/features/ui/pages/tabs/message_tab/chat_screen.dart';
import 'package:sokon/features/ui/pages/tabs/profile_tab/my_bookings/my_bookings_screen.dart';
import 'package:sokon/features/ui/pages/tabs/profile_tab/settings/settings_screen.dart';
import 'package:sokon/features/ui/pages/top_location_screen/top_location_screen.dart';

import 'core/cache/provider/apartment_list_provider.dart';
import 'core/cache/provider/location_provider.dart';
import 'core/utils/app_routes.dart';
import 'features/ui/auth/login/login_screen.dart';
import 'features/ui/pages/add_apartment/add_apartment.dart';
import 'features/ui/pages/apartment_details_screen/apartment_details.dart';
import 'features/ui/pages/featured_estates_screen/featured_estate_screen.dart';
import 'features/ui/pages/nearby_estate_screen/nearby_estate_screen.dart';
import 'features/ui/pages/notifaction_screen/notifaction_screen.dart';
import 'features/ui/pages/tabs/profile_tab/add_card_screen/add_card_screen.dart';
import 'features/ui/pages/tabs/profile_tab/my_apartments/my_apartments_screen.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load(fileName: ".env");

  runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LocationProvider()),
        ChangeNotifierProvider(create: (context) => ApartmentListProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
      ],
      child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(393, 852),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
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
                AppRoutes.apartmentDetailsRoute: (context) => ApartmentDetails(),
                AppRoutes.locationPickerRoute: (context) => LocationPicker(),
                AppRoutes.topLocationRoute: (context) => TopLocationScreen(),
                AppRoutes.nearbyEstateRoute: (context) => NearbyEstateScreen(),
                AppRoutes.featuredEstateRoute: (context) => FeaturedEstateScreen(),
                AppRoutes.settingsScreenRoute: (context) => SettingsScreen(),
                AppRoutes.notificationRoute: (context) => NotifactionScreen(),
                AppRoutes.addCardRoute: (context) => AddCardScreen(),
                AppRoutes.bookingRoute: (context) => BookingScreen(),
                AppRoutes.myApartmentsRoute: (context) => MyApartmentsScreen(),
                AppRoutes.chatRoute: (context) => const ChatScreen(),
                AppRoutes.myBookingsRoute: (context) => const MyBookingsScreen(),
              },
              theme: ThemeData.light());
        });
  }
}
