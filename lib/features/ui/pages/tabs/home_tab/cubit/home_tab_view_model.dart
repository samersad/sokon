import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:injectable/injectable.dart';

import '../../../../../../core/cache/cubit_manger/apartment_view_model.dart';
import '../../../../../../core/cache/cubit_manger/location_view_model.dart';
import '../../../../../../core/constants/university_locations.dart';
import '../../../../../../core/model/ApartmentResponse.dart';
import '../../../../../../core/model/district_summary.dart';
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
      isLoadingEstates: true,
      clearErrorMessage: true,
    ));

    try {
      await _loadApartments();
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(
        isLoadingEstates: false,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Called when the user selects a different university from the selector.
  void selectUniversity(University university) {
    if (isClosed) return;
    emit(state.copyWith(
      selectedUniversity: university,
      nearbyApartments: _buildNearbyApartments(
        apartments: state.allApartments,
        referenceLocation: university.location,
      ),
    ));
  }

  void clearErrorMessage() {
    if (isClosed) return;
    emit(state.copyWith(clearErrorMessage: true));
  }

  Future<void> _loadApartments() async {
    await apartmentViewModel.getAllApartments();
    final allApartments = apartmentViewModel.apartmentList;

    if (isClosed) return;
    emit(state.copyWith(
      isLoadingEstates: false,
      allApartments: allApartments,
      featuredApartments: _buildFeaturedApartments(allApartments),
      nearbyApartments: _buildNearbyApartments(
        apartments: allApartments,
        referenceLocation: state.selectedUniversity.location,
      ),
      topDistricts: _buildTopDistricts(allApartments),
    ));
  }

  List<ApartmentResponse> _buildFeaturedApartments(List<ApartmentResponse> apartments) {
    final featured = List<ApartmentResponse>.from(apartments);
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

  List<DistrictSummary> _buildTopDistricts(List<ApartmentResponse> apartments) {
    return buildDistrictSummaries(apartments).take(5).toList();
  }

  List<ApartmentResponse> _buildNearbyApartments({
    required List<ApartmentResponse> apartments,
    required LatLng referenceLocation,
  }) {
    final nearby = apartments
        .where((apartment) => apartment.lat != null && apartment.lng != null)
        .toList();

    nearby.sort((a, b) {
      final distanceA = Geolocator.distanceBetween(
        referenceLocation.latitude,
        referenceLocation.longitude,
        a.lat!,
        a.lng!,
      );
      final distanceB = Geolocator.distanceBetween(
        referenceLocation.latitude,
        referenceLocation.longitude,
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
