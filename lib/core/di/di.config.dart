// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:sokon/core/cache/cubit_manger/apartment_view_model.dart'
    as _i284;
import 'package:sokon/core/cache/cubit_manger/location_view_model.dart' as _i71;
import 'package:sokon/core/cache/cubit_manger/my_booking_view_model.dart'
    as _i253;
import 'package:sokon/core/cache/cubit_manger/user_view_model.dart' as _i910;
import 'package:sokon/data/repository/apartment/data_sources/remote/apartment_remote_data_source.dart'
    as _i309;
import 'package:sokon/data/repository/apartment/data_sources/remote/impl/apartment_remote_data_impl.dart'
    as _i268;
import 'package:sokon/data/repository/apartment/repository/apartment_repository.dart'
    as _i139;
import 'package:sokon/data/repository/apartment/repository/impl/apartment_repository_impl.dart'
    as _i57;
import 'package:sokon/data/repository/auth/data_sources/remote/auth_remote_data_source.dart'
    as _i437;
import 'package:sokon/data/repository/auth/data_sources/remote/impl/auth_remote_data_impl.dart'
    as _i691;
import 'package:sokon/data/repository/auth/repository/auth_repository.dart'
    as _i977;
import 'package:sokon/data/repository/auth/repository/impl/auth_repository_ipml.dart'
    as _i841;
import 'package:sokon/data/repository/booking/data_sources/remote/booking_remote_data_source.dart'
    as _i7;
import 'package:sokon/data/repository/booking/data_sources/remote/impl/booking_remote_data_impl.dart'
    as _i1022;
import 'package:sokon/data/repository/booking/repository/booking_repository.dart'
    as _i881;
import 'package:sokon/data/repository/booking/repository/impl/booking_repository_impl.dart'
    as _i916;
import 'package:sokon/data/repository/chat/data_sources/remote/chat_remote_data_source.dart'
    as _i1008;
import 'package:sokon/data/repository/chat/data_sources/remote/impl/chat_remote_data_impl.dart'
    as _i138;
import 'package:sokon/data/repository/chat/repository/chat_repository.dart'
    as _i12;
import 'package:sokon/data/repository/chat/repository/impl/chat_repository_impl.dart'
    as _i543;
import 'package:sokon/features/ui/auth/login/cubit/login_view_model.dart'
    as _i682;
import 'package:sokon/features/ui/auth/register/cubit/register_view_model.dart'
    as _i992;
import 'package:sokon/features/ui/pages/add_apartment/cubit/add_apartment_view_model.dart'
    as _i549;
import 'package:sokon/features/ui/pages/apartment_details_screen/cubit/apartment_details_view_model.dart'
    as _i964;
import 'package:sokon/features/ui/pages/booking_screen/cubit/booking_view_model.dart'
    as _i186;
import 'package:sokon/features/ui/pages/featured_estates_screen/cubit/featured_estates_view_model.dart'
    as _i18;
import 'package:sokon/features/ui/pages/home_screen/cubit/home_screen_view_model.dart'
    as _i286;
import 'package:sokon/features/ui/pages/nearby_estate_screen/cubit/nearby_estate_view_model.dart'
    as _i1039;
import 'package:sokon/features/ui/pages/tabs/home_tab/cubit/home_tab_view_model.dart'
    as _i244;
import 'package:sokon/features/ui/pages/tabs/message_tab/cubit/chat_view_model.dart'
    as _i509;
import 'package:sokon/features/ui/pages/tabs/message_tab/cubit/message_view_model.dart'
    as _i1041;
import 'package:sokon/features/ui/pages/tabs/profile_tab/cubit/profile_view_model.dart'
    as _i951;
import 'package:sokon/features/ui/pages/tabs/profile_tab/my_bookings/cubit/my_bookings_view_model.dart'
    as _i442;
import 'package:sokon/features/ui/pages/tabs/profile_tab/settings/cubit/settings_view_model.dart'
    as _i954;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.factory<_i253.MyBookingViewModel>(() => _i253.MyBookingViewModel());
    gh.factory<_i964.ApartmentDetailsViewModel>(
      () => _i964.ApartmentDetailsViewModel(),
    );
    gh.factory<_i286.HomeScreenViewModel>(() => _i286.HomeScreenViewModel());
    gh.lazySingleton<_i71.LocationViewModel>(() => _i71.LocationViewModel());
    gh.lazySingleton<_i910.UserViewModel>(() => _i910.UserViewModel());
    gh.factory<_i309.ApartmentRemoteDataSource>(
      () => _i268.ApartmentRemoteDataImpl(),
    );
    gh.factory<_i7.BookingRemoteDataSource>(
      () => _i1022.BookingRemoteDataImpl(),
    );
    gh.factory<_i881.BookingRepository>(
      () => _i916.BookingRepositoryImpl(gh<_i7.BookingRemoteDataSource>()),
    );
    gh.factory<_i1008.ChatRemoteDataSource>(() => _i138.ChatRemoteDataImpl());
    gh.factory<_i437.AuthRemoteDataSource>(() => _i691.AuthRemoteDataImpl());
    gh.factory<_i977.AuthRepository>(
      () => _i841.AuthRepositoryImpl(gh<_i437.AuthRemoteDataSource>()),
    );
    gh.factory<_i186.BookingViewModel>(
      () => _i186.BookingViewModel(
        gh<_i910.UserViewModel>(),
        gh<_i881.BookingRepository>(),
      ),
    );
    gh.factory<_i954.SettingsViewModel>(
      () => _i954.SettingsViewModel(
        gh<_i910.UserViewModel>(),
        gh<_i977.AuthRepository>(),
      ),
    );
    gh.factory<_i12.ChatRepository>(
      () => _i543.ChatRepositoryImpl(gh<_i1008.ChatRemoteDataSource>()),
    );
    gh.factory<_i139.ApartmentRepository>(
      () => _i57.ApartmentRepositoryImpl(gh<_i309.ApartmentRemoteDataSource>()),
    );
    gh.factory<_i442.MyBookingsViewModel>(
      () => _i442.MyBookingsViewModel(gh<_i881.BookingRepository>()),
    );
    gh.factory<_i951.ProfileViewModel>(
      () => _i951.ProfileViewModel(
        gh<_i977.AuthRepository>(),
        gh<_i910.UserViewModel>(),
      ),
    );
    gh.factory<_i682.LoginViewModel>(
      () => _i682.LoginViewModel(gh<_i977.AuthRepository>()),
    );
    gh.factory<_i992.RegisterViewModel>(
      () => _i992.RegisterViewModel(gh<_i977.AuthRepository>()),
    );
    gh.factory<_i509.ChatViewModel>(
      () => _i509.ChatViewModel(gh<_i12.ChatRepository>()),
    );
    gh.factory<_i1041.MessageViewModel>(
      () => _i1041.MessageViewModel(gh<_i12.ChatRepository>()),
    );
    gh.lazySingleton<_i284.ApartmentViewModel>(
      () => _i284.ApartmentViewModel(gh<_i139.ApartmentRepository>()),
    );
    gh.factory<_i549.AddApartmentViewModel>(
      () => _i549.AddApartmentViewModel(gh<_i139.ApartmentRepository>()),
    );
    gh.factory<_i244.HomeTabViewModel>(
      () => _i244.HomeTabViewModel(
        gh<_i284.ApartmentViewModel>(),
        gh<_i71.LocationViewModel>(),
      ),
    );
    gh.factory<_i18.FeaturedEstateViewModel>(
      () => _i18.FeaturedEstateViewModel(gh<_i284.ApartmentViewModel>()),
    );
    gh.factory<_i1039.NearbyEstateViewModel>(
      () => _i1039.NearbyEstateViewModel(gh<_i284.ApartmentViewModel>()),
    );
    return this;
  }
}
