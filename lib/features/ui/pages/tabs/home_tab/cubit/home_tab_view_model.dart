import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../../../core/cache/cubit_manger/apartment_view_model.dart';
import '../../../../../../core/cache/cubit_manger/location_view_model.dart';
import 'home_tab_states.dart';

class HomeTabViewModel extends Cubit<HomeTabStates> {
  final ApartmentViewModel apartmentViewModel;
  final LocationViewModel locationViewModel;

  HomeTabViewModel(this.apartmentViewModel, this.locationViewModel) : super(HomeTabInitial());

  Future<void> getUserLocationData() async {
    // emit(HomeTabLoading());
    try {
      await locationViewModel.getCurrentLocation();
      
      final userLocation = locationViewModel.userLocation;

      emit(HomeTabUserLocationLoaded(
        userLocation: userLocation,
      ));
    } catch (e) {
      emit(HomeTabError(e.toString()));
    }
  }

  Future<void> getFeaturedEstateData() async {
    emit(HomeTabLoading());
    try {

      await apartmentViewModel.getAllApartments();

      final allApartments = apartmentViewModel.apartmentList;


      emit(HomeTabFeaturedEstateLoaded(
        allApartments: allApartments,
      ));
    } catch (e) {
      emit(HomeTabError(e.toString()));
    }
  }

  Future<void> getNearbyEstateData() async {
    emit(HomeTabLoading());
    try {

      await apartmentViewModel.getAllApartments();

      final allApartments = apartmentViewModel.apartmentList;


      emit(HomeTabNearbyEstateLoaded(
        allApartments: allApartments,
      ));
    } catch (e) {
      emit(HomeTabError(e.toString()));
    }
  }
}
