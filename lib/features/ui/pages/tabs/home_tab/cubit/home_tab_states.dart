import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../../../core/model/apartment.dart';
import '../../../../../../core/model/district_summary.dart';

class HomeTabStates {
  final bool isLoadingLocation;
  final bool isLoadingEstates;
  final LatLng? userLocation;
  final String? userAddress;
  final List<Apartment> allApartments;
  final List<Apartment> featuredApartments;
  final List<Apartment> nearbyApartments;
  final List<DistrictSummary> topDistricts;
  final String? errorMessage;

  const HomeTabStates({
    this.isLoadingLocation = false,
    this.isLoadingEstates = false,
    this.userLocation,
    this.userAddress,
    this.allApartments = const [],
    this.featuredApartments = const [],
    this.nearbyApartments = const [],
    this.topDistricts = const [],
    this.errorMessage,
  });

  factory HomeTabStates.initial() => const HomeTabStates();

  HomeTabStates copyWith({
    bool? isLoadingLocation,
    bool? isLoadingEstates,
    LatLng? userLocation,
    bool clearUserLocation = false,
    String? userAddress,
    bool clearUserAddress = false,
    List<Apartment>? allApartments,
    List<Apartment>? featuredApartments,
    List<Apartment>? nearbyApartments,
    List<DistrictSummary>? topDistricts,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return HomeTabStates(
      isLoadingLocation: isLoadingLocation ?? this.isLoadingLocation,
      isLoadingEstates: isLoadingEstates ?? this.isLoadingEstates,
      userLocation: clearUserLocation ? null : (userLocation ?? this.userLocation),
      userAddress: clearUserAddress ? null : (userAddress ?? this.userAddress),
      allApartments: allApartments ?? this.allApartments,
      featuredApartments: featuredApartments ?? this.featuredApartments,
      nearbyApartments: nearbyApartments ?? this.nearbyApartments,
      topDistricts: topDistricts ?? this.topDistricts,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
