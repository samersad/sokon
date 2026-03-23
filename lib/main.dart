import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sokon/core/cache/cubit_manger/apartment_view_model.dart';
import 'package:sokon/core/cache/cubit_manger/location_view_model.dart';
import 'package:sokon/core/cache/cubit_manger/user_view_model.dart';
import 'package:sokon/features/ui/auth/forget_password/forget_password_screen.dart';
import 'package:sokon/features/ui/auth/forget_password/forget_password_screen2.dart';
import 'package:sokon/features/ui/auth/register/register_screen.dart';
import 'package:sokon/features/ui/auth/verification/verification_screen.dart';
import 'package:sokon/features/ui/location_picker/location_picker.dart';
import 'package:sokon/features/ui/pages/add_apartment/cubit/add_apartment_view_model.dart';
import 'package:sokon/features/ui/pages/apartment_details_screen/cubit/apartment_details_view_model.dart';
import 'package:sokon/features/ui/pages/booking_screen/booking_screen.dart';
import 'package:sokon/features/ui/pages/booking_screen/cubit/booking_view_model.dart';
import 'package:sokon/features/ui/pages/featured_estates_screen/cubit/featured_estates_view_model.dart';
import 'package:sokon/features/ui/pages/home_screen/cubit/home_screen_view_model.dart';
import 'package:sokon/features/ui/pages/home_screen/home_screen.dart';
import 'package:sokon/features/ui/pages/nearby_estate_screen/cubit/nearby_estate_view_model.dart';
import 'package:sokon/features/ui/pages/tabs/home_tab/cubit/home_tab_view_model.dart';
import 'package:sokon/features/ui/pages/tabs/message_tab/chat_screen.dart';
import 'package:sokon/features/ui/pages/tabs/message_tab/cubit/message_view_model.dart';
import 'package:sokon/features/ui/pages/tabs/profile_tab/my_bookings/my_bookings_screen.dart';
import 'package:sokon/features/ui/pages/tabs/profile_tab/settings/settings_screen.dart';
import 'package:sokon/features/ui/pages/top_location_screen/top_location_screen.dart';

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

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => UserViewModel()),
        BlocProvider(create: (context) => HomeScreenViewModel()),
        BlocProvider(create: (context) => LocationViewModel()),
        BlocProvider(create: (context) => ApartmentViewModel()),
        BlocProvider(
          create: (context) => HomeTabViewModel(
            context.read<ApartmentViewModel>(),
            context.read<LocationViewModel>(),
          ),
        ),
        BlocProvider(
          create: (context) => NearbyEstateViewModel(
            context.read<ApartmentViewModel>(),
          ),
        ),
        BlocProvider(
          create: (context) => FeaturedEstateViewModel(
            context.read<ApartmentViewModel>(),
          ),
        ),
        BlocProvider(
          create: (context) => AddApartmentViewModel(
            context.read<UserViewModel>(),
            context.read<LocationViewModel>(),
          ),
        ),
        BlocProvider(create: (context) => ApartmentDetailsViewModel()),
        BlocProvider(
          create: (context) => BookingViewModel(context.read<UserViewModel>()),
        ),
        BlocProvider(create: (context) => MessageViewModel()),
      ],
      child: const MyApp(),
    ),
  );
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
            AppRoutes.homeScreenRoute: (context) => const HomeScreen(),
            AppRoutes.loginRoute: (context) => const LoginScreen(),
            AppRoutes.registerRoute: (context) => const RegisterScreen(),
            AppRoutes.forgetPasswordRoute: (context) => const ForgetPasswordScreen(),
            AppRoutes.verificationRoute: (context) => const VerificationScreen(),
            AppRoutes.forgetPassword2Route: (context) => const ForgetPasswordScreen2(),
            AppRoutes.addApartmentRoute: (context) => const AddApartment(),
            AppRoutes.apartmentDetailsRoute: (context) => const ApartmentDetails(),
            AppRoutes.locationPickerRoute: (context) => const LocationPicker(),
            AppRoutes.topLocationRoute: (context) => const TopLocationScreen(),
            AppRoutes.nearbyEstateRoute: (context) => const NearbyEstateScreen(),
            AppRoutes.featuredEstateRoute: (context) => const FeaturedEstateScreen(),
            AppRoutes.settingsScreenRoute: (context) => const SettingsScreen(),
            AppRoutes.notificationRoute: (context) => const NotifactionScreen(),
            AppRoutes.addCardRoute: (context) => const AddCardScreen(),
            AppRoutes.bookingRoute: (context) => const BookingScreen(),
            AppRoutes.myApartmentsRoute: (context) => const MyApartmentsScreen(),
            AppRoutes.chatRoute: (context) => const ChatScreen(),
            AppRoutes.myBookingsRoute: (context) => const MyBookingsScreen(),
          },
          theme: ThemeData.light(),
        );
      },
    );
  }
}
