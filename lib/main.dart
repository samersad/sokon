import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sokon/core/cache/cubit_manger/apartment_view_model.dart';
import 'package:sokon/core/cache/cubit_manger/language_view_model.dart';
import 'package:sokon/core/cache/cubit_manger/location_view_model.dart';
import 'package:sokon/core/cache/cubit_manger/theme_view_model.dart';
import 'package:sokon/core/cache/cubit_manger/user_states.dart';
import 'package:sokon/core/cache/cubit_manger/user_view_model.dart';
import 'package:sokon/core/model/RegisterResponse.dart';
import 'package:sokon/core/model/ApartmentResponse.dart';
import 'package:sokon/features/ui/auth/forget_password/forget_password_screen.dart';
import 'package:sokon/features/ui/auth/forget_password/forget_password_screen2.dart';
import 'package:sokon/features/ui/auth/register/register_screen.dart';
import 'package:sokon/features/ui/auth/verification/verification_screen.dart';
import 'package:sokon/features/ui/location_picker/location_picker.dart';
import 'package:sokon/features/ui/location_picker/user_location_picker.dart';
import 'package:sokon/features/ui/pages/add_apartment/edit_apartment.dart';
import 'package:sokon/features/ui/pages/booking_screen/booking_screen.dart';
import 'package:sokon/features/ui/pages/district_apartments_screen/district_apartments_screen.dart';
import 'package:sokon/features/ui/pages/home_screen/home_screen.dart';
import 'package:sokon/features/ui/pages/tabs/message_tab/chat_screen.dart';
import 'package:sokon/features/ui/pages/tabs/home_tab/home_map_screen.dart';
import 'package:sokon/features/ui/pages/tabs/profile_tab/my_bookings/my_bookings_screen.dart';
import 'package:sokon/features/ui/pages/tabs/profile_tab/owner_booking_requests/owner_booking_requests_screen.dart';
import 'package:sokon/features/ui/pages/tabs/profile_tab/settings/settings_screen.dart';
import 'package:sokon/features/ui/pages/top_location_screen/top_location_screen.dart';
import 'core/cache/cubit_manger/language_state.dart';
import 'core/cache/shared_prefs_helper.dart';
import 'core/di/di.dart';
import 'core/services/firebase_cloud_messaging.dart';
import 'core/utils/app_routes.dart';
import 'core/utils/app_theme.dart';
import 'features/ui/auth/login/login_screen.dart';
import 'features/ui/pages/add_apartment/add_apartment.dart';
import 'features/ui/pages/apartment_details_screen/apartment_details.dart';
import 'features/ui/pages/featured_estates_screen/featured_estate_screen.dart';
import 'features/ui/pages/nearby_estate_screen/nearby_estate_screen.dart';
import 'features/ui/pages/notifaction_screen/notifaction_screen.dart';
import 'features/ui/pages/tabs/profile_tab/add_card_screen/add_card_screen.dart';
import 'features/ui/pages/tabs/profile_tab/my_apartments/my_apartments_screen.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp();

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );
  await FirebaseCloudMessaging.init();

  await SharedPrefsHelper.init();
  await configureDependencies();
  final userViewModel = getIt<UserViewModel>();
  final locationViewModel = getIt<LocationViewModel>();
  final apartmentViewModel = getIt<ApartmentViewModel>();
  final themeViewModel = ThemeViewModel();
  final languageViewModel = LanguageViewModel();
  String routeName;
  RegisterUser? restoredUser;
  final cachedUser = SharedPrefsHelper.getData(key: "cached_user");
  final cachedToken = SharedPrefsHelper.getData(key: "token");

  if (cachedToken is String &&
      cachedToken.isNotEmpty &&
      cachedUser is String &&
      cachedUser.isNotEmpty) {
    final decodedUser = jsonDecode(cachedUser);
    if (decodedUser is Map<String, dynamic>) {
      restoredUser = RegisterUser.fromJson(decodedUser);
    }
  }

  // Register the listener BEFORE calling updateUser so the cold-start
  // UserUpdated emission is not missed. The auth repository writes
  // `token` and `cached_user` into SharedPrefs *before* returning the
  // user object, so when syncTokenForUser fires it always finds fresh data.
  // This single listener covers all paths: cold start, login, register,
  // and Google sign-in — no extra explicit call is needed.
  userViewModel.stream.listen((state) async {
    if (state is UserUpdated) {
      if (state.user == null) {
        await FirebaseCloudMessaging.clearTokenForUser(null);
      } else {
        await FirebaseCloudMessaging.syncTokenForUser(state.user!.id);
      }
    }
  });
  userViewModel.updateUser(restoredUser);

  final restoredRole = restoredUser?.role?.trim();
  if (cachedToken is! String ||
      cachedToken.isEmpty ||
      restoredUser == null ||
      restoredRole == null ||
      restoredRole.isEmpty) {
    await SharedPrefsHelper.removeData(key: "token");
    await SharedPrefsHelper.removeData(key: "cached_user");
    routeName = AppRoutes.loginRoute;
  } else {
    routeName = AppRoutes.homeScreenRoute;
  }

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider.value(value: userViewModel),
        BlocProvider.value(value: locationViewModel),
        BlocProvider.value(value: apartmentViewModel),
        BlocProvider.value(value: themeViewModel),
        BlocProvider.value(value: languageViewModel),
      ],
      child: MyApp(routeName: routeName),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.routeName});
  final String routeName;

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(393, 852),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return BlocBuilder<ThemeViewModel, ThemeState>(
          builder: (context, themeState) {
            return BlocBuilder<LanguageViewModel, LanguageState>(
              builder: (context, languageState) {
                return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  initialRoute: routeName,
                  routes: {
                    AppRoutes.homeScreenRoute: (context) => const HomeScreen(),
                    AppRoutes.homeMapRoute: (context) {
                      final arguments =
                          ModalRoute.of(context)!.settings.arguments
                              as HomeMapArguments;
                      return HomeMapScreen(arguments: arguments);
                    },
                    AppRoutes.loginRoute: (context) => const LoginScreen(),
                    AppRoutes.registerRoute: (context) => const RegisterScreen(),
                    AppRoutes.forgetPasswordRoute: (context) =>
                        const ForgetPasswordScreen(),
                    AppRoutes.verificationRoute: (context) =>
                        const VerificationScreen(),
                    AppRoutes.forgetPassword2Route: (context) =>
                        const ForgetPasswordScreen2(),
                    AppRoutes.addApartmentRoute: (context) => const AddApartment(),
                    AppRoutes.editApartmentRoute: (context) {
                      final apartment =
                          ModalRoute.of(context)!.settings.arguments
                              as ApartmentResponse;
                      return EditApartment(apartment: apartment);
                    },
                    AppRoutes.apartmentDetailsRoute: (context) =>
                        const ApartmentDetails(),
                    AppRoutes.locationPickerRoute: (context) =>
                        const LocationPicker(),
                    AppRoutes.topLocationRoute: (context) =>
                        const TopLocationScreen(),
                    AppRoutes.districtApartmentsRoute: (context) =>
                        const DistrictApartmentsScreen(),
                    AppRoutes.nearbyEstateRoute: (context) =>
                        const NearbyEstateScreen(),
                    AppRoutes.featuredEstateRoute: (context) =>
                        const FeaturedEstateScreen(),
                    AppRoutes.settingsScreenRoute: (context) =>
                        const SettingsScreen(),
                    AppRoutes.notificationRoute: (context) =>
                        const NotifactionScreen(),
                    AppRoutes.addCardRoute: (context) => const AddCardScreen(),
                    AppRoutes.bookingRoute: (context) => const BookingScreen(),
                    AppRoutes.myApartmentsRoute: (context) =>
                        const MyApartmentsScreen(),
                    AppRoutes.chatRoute: (context) => const ChatScreen(),
                    AppRoutes.myBookingsRoute: (context) =>
                        const MyBookingsScreen(),
                    AppRoutes.ownerBookingRequestsRoute: (context) =>
                        const OwnerBookingRequestsScreen(),
                    AppRoutes.userLocationPickerRoute: (context) =>
                        const UserLocationPicker(),
                  },
                  locale: languageState.locale,
                  localizationsDelegates: AppLocalizations.localizationsDelegates,
                  supportedLocales: AppLocalizations.supportedLocales,
                  theme: AppTheme.lightTheme,
                  darkTheme: AppTheme.darkTheme,
                  themeMode: themeState.themeMode,
                );
              },
            );
          },
        );
      },
    );
  }
}
