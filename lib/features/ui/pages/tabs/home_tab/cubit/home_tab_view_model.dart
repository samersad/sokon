import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:injectable/injectable.dart';

import '../../../../../../core/cache/cubit_manger/apartment_view_model.dart';
import '../../../../../../core/cache/cubit_manger/location_view_model.dart';
import '../../../../../../core/model/apartment.dart';
import 'home_tab_states.dart';

@injectable
class HomeTabViewModel extends Cubit<HomeTabStates> {
  final ApartmentViewModel apartmentViewModel;
  final LocationViewModel locationViewModel;

  HomeTabViewModel(this.apartmentViewModel, this.locationViewModel)
      : super(HomeTabStates.initial());

  Future<void> loadHomeData() async {
    if (isClosed) return;
    emit(state.copyWith(
      isLoadingLocation: true,
      isLoadingEstates: true,
      clearErrorMessage: true,
    ));

    try {
      await Future.wait([
        _loadUserLocation(),
        _loadApartments(),
      ]);
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(
        isLoadingLocation: false,
        isLoadingEstates: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> getUserLocationData() async {
    if (isClosed) return;
    emit(state.copyWith(
      isLoadingLocation: true,
      clearErrorMessage: true,
    ));

    try {
      await _loadUserLocation();
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(
        isLoadingLocation: false,
        errorMessage: e.toString(),
      ));
    }
  }

  void refreshUserLocation() {
    final userLocation = locationViewModel.userLocation;
    final userAddress = locationViewModel.userAddress;

    if (isClosed) return;
    emit(state.copyWith(
      isLoadingLocation: false,
      userLocation: userLocation,
      userAddress: userAddress,
      nearbyApartments: _buildNearbyApartments(
        apartments: apartmentViewModel.apartmentList,
        userLocation: userLocation,
      ),
      clearErrorMessage: true,
    ));
  }

  void clearErrorMessage() {
    if (isClosed) return;
    emit(state.copyWith(clearErrorMessage: true));
  }

  Future<void> _loadUserLocation() async {
    await locationViewModel.getCurrentLocation();
    final userLocation = locationViewModel.userLocation;
    final userAddress = locationViewModel.userAddress;

    if (isClosed) return;
    emit(state.copyWith(
      isLoadingLocation: false,
      userLocation: userLocation,
      userAddress: userAddress,
      nearbyApartments: _buildNearbyApartments(
        apartments: apartmentViewModel.apartmentList,
        userLocation: userLocation,
      ),
    ));
  }

  Future<void> _loadApartments() async {
    await apartmentViewModel.getAllApartments();
    final allApartments = apartmentViewModel.apartmentList;

    if (isClosed) return;
    emit(state.copyWith(
      isLoadingEstates: false,
      featuredApartments: _buildFeaturedApartments(allApartments),
      nearbyApartments: _buildNearbyApartments(
        apartments: allApartments,
        userLocation: state.userLocation,
      ),
    ));
  }

  List<Apartment> _buildFeaturedApartments(List<Apartment> apartments) {
    final featured = List<Apartment>.from(apartments);
    featured.sort((a, b) {
      final aDate = a.createdAt;
      final bDate = b.createdAt;
      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;
      return bDate.compareTo(aDate);
    });
    return featured.take(5).toList();
  }

  List<Apartment> _buildNearbyApartments({
    required List<Apartment> apartments,
    required LatLng? userLocation,
  }) {
    if (userLocation == null) {
      return apartments.take(5).toList();
    }

    final nearby = apartments
        .where((apartment) => apartment.lat != null && apartment.lng != null)
        .toList();

    nearby.sort((a, b) {
      final distanceA = Geolocator.distanceBetween(
        userLocation.latitude,
        userLocation.longitude,
        a.lat!,
        a.lng!,
      );
      final distanceB = Geolocator.distanceBetween(
        userLocation.latitude,
        userLocation.longitude,
        b.lat!,
        b.lng!,
      );
      return distanceA.compareTo(distanceB);
    });

    if (nearby.isNotEmpty) {
      return nearby.take(5).toList();
    }

    return apartments.take(5).toList();
  }
}
