import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../../../core/constants/university_locations.dart';
import '../../../../../../core/model/ApartmentResponse.dart';
import '../../../../../../core/model/district_summary.dart';

class HomeTabStates {
  final bool isLoadingEstates;
  final University selectedUniversity;
  final List<ApartmentResponse> allApartments;
  final List<ApartmentResponse> featuredApartments;
  final List<ApartmentResponse> nearbyApartments;
  final List<DistrictSummary> topDistricts;
  final String? errorMessage;

  const HomeTabStates({
    this.isLoadingEstates = false,
    this.selectedUniversity = const University(
      name: 'Assiut University',
      location: LatLng(27.187452436450204, 31.170279713778406),
    ),
    this.allApartments = const [],
    this.featuredApartments = const [],
    this.nearbyApartments = const [],
    this.topDistricts = const [],
    this.errorMessage,
  });

  factory HomeTabStates.initial() => HomeTabStates(
        selectedUniversity: UniversityLocations.defaultUniversity,
      );

  HomeTabStates copyWith({
    bool? isLoadingEstates,
    University? selectedUniversity,
    List<ApartmentResponse>? allApartments,
    List<ApartmentResponse>? featuredApartments,
    List<ApartmentResponse>? nearbyApartments,
    List<DistrictSummary>? topDistricts,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return HomeTabStates(
      isLoadingEstates: isLoadingEstates ?? this.isLoadingEstates,
      selectedUniversity: selectedUniversity ?? this.selectedUniversity,
      allApartments: allApartments ?? this.allApartments,
      featuredApartments: featuredApartments ?? this.featuredApartments,
      nearbyApartments: nearbyApartments ?? this.nearbyApartments,
      topDistricts: topDistricts ?? this.topDistricts,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
