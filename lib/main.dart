import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sokon/core/cache/cubit_manger/apartment_view_model.dart';
import 'package:sokon/core/cache/cubit_manger/location_view_model.dart';
import 'package:sokon/core/cache/cubit_manger/user_view_model.dart';
import 'package:sokon/core/model/apartment.dart';
import 'package:sokon/data/repository/auth/repository/auth_repository.dart';
import 'package:sokon/features/ui/auth/forget_password/forget_password_screen.dart';
import 'package:sokon/features/ui/auth/forget_password/forget_password_screen2.dart';
import 'package:sokon/features/ui/auth/register/register_screen.dart';
import 'package:sokon/features/ui/auth/verification/verification_screen.dart';
import 'package:sokon/features/ui/location_picker/location_picker.dart';
import 'package:sokon/features/ui/location_picker/user_location_picker.dart';
import 'package:sokon/features/ui/pages/add_apartment/edit_apartment.dart';
import 'package:sokon/features/ui/pages/booking_screen/booking_screen.dart';
import 'package:sokon/features/ui/pages/home_screen/home_screen.dart';
import 'package:sokon/features/ui/pages/tabs/message_tab/chat_screen.dart';
import 'package:sokon/features/ui/pages/tabs/profile_tab/my_bookings/my_bookings_screen.dart';
import 'package:sokon/features/ui/pages/tabs/profile_tab/settings/settings_screen.dart';
import 'package:sokon/features/ui/pages/top_location_screen/top_location_screen.dart';
import 'core/di/di.dart';
import 'core/utils/app_routes.dart';
import 'features/ui/auth/login/login_screen.dart';
import 'features/ui/pages/add_apartment/add_apartment.dart';
import 'features/ui/pages/apartment_details_screen/apartment_details.dart';
import 'features/ui/pages/featured_estates_screen/featured_estate_screen.dart';
import 'features/ui/pages/nearby_estate_screen/nearby_estate_screen.dart';
import 'features/ui/pages/notifaction_screen/notifaction_screen.dart';
import 'features/ui/pages/tabs/profile_tab/add_card_screen/add_card_screen.dart';
import 'features/ui/pages/tabs/profile_tab/my_apartments/my_apartments_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  await configureDependencies();
  final userViewModel = getIt<UserViewModel>();
  final locationViewModel = getIt<LocationViewModel>();
  final apartmentViewModel = getIt<ApartmentViewModel>();
  final authRepository = getIt<AuthRepository>();

  final restoredUser = await authRepository.restoreSession();
  userViewModel.updateUser(restoredUser);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider.value(value: userViewModel),
        BlocProvider.value(value: locationViewModel),
        BlocProvider.value(value: apartmentViewModel),
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
        final initialRoute = context.read<UserViewModel>().user == null
            ? AppRoutes.loginRoute
            : AppRoutes.homeScreenRoute;

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          initialRoute: initialRoute,
          routes: {
            AppRoutes.homeScreenRoute: (context) => const HomeScreen(),
            AppRoutes.loginRoute: (context) => const LoginScreen(),
            AppRoutes.registerRoute: (context) => const RegisterScreen(),
            AppRoutes.forgetPasswordRoute: (context) => const ForgetPasswordScreen(),
            AppRoutes.verificationRoute: (context) => const VerificationScreen(),
            AppRoutes.forgetPassword2Route: (context) => const ForgetPasswordScreen2(),
            AppRoutes.addApartmentRoute: (context) => const AddApartment(),
            AppRoutes.editApartmentRoute: (context) {
              final apartment = ModalRoute.of(context)!.settings.arguments as Apartment;
              return EditApartment(apartment: apartment);
            },
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
            AppRoutes.userLocationPickerRoute: (context) => const UserLocationPicker(),
          },
          theme: ThemeData.light(),
        );
      },
    );
  }
}
