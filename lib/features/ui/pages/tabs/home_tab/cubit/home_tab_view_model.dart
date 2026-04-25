import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../../core/cache/cubit_manger/apartment_view_model.dart';
import '../../../../../../core/cache/cubit_manger/location_view_model.dart';
import 'home_tab_states.dart';

@injectable
class HomeTabViewModel extends Cubit<HomeTabStates> {
  final ApartmentViewModel apartmentViewModel;
  final LocationViewModel locationViewModel;

  HomeTabViewModel(this.apartmentViewModel, this.locationViewModel)
      : super(HomeTabInitial());

  Future<void> getUserLocationData() async {
    try {
      await locationViewModel.getCurrentLocation();
      emit(HomeTabUserLocationLoaded(
        userLocation: locationViewModel.userLocation,
      ));
      emit(HomeTabUserAddressLoaded(
        address: locationViewModel.userAddress,
      ));
    } catch (e) {
      emit(HomeTabError(e.toString()));
    }
  }

  void refreshUserLocation() {
    emit(HomeTabUserLocationLoaded(
      userLocation: locationViewModel.userLocation,
    ));
    emit(HomeTabUserAddressLoaded(
      address: locationViewModel.userAddress,
    ));
  }

  Future<void> getFeaturedEstateData() async {
    emit(HomeTabLoading());
    try {
      await apartmentViewModel.getAllApartments();
      emit(HomeTabFeaturedEstateLoaded(
        allApartments: apartmentViewModel.apartmentList,
      ));
    } catch (e) {
      emit(HomeTabError(e.toString()));
    }
  }

  Future<void> getNearbyEstateData() async {
    emit(HomeTabLoading());
    try {
      await apartmentViewModel.getAllApartments();
      emit(HomeTabNearbyEstateLoaded(
        allApartments: apartmentViewModel.apartmentList,
      ));
    } catch (e) {
      emit(HomeTabError(e.toString()));
    }
  }
}
