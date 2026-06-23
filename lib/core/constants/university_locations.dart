import 'package:google_maps_flutter/google_maps_flutter.dart';

class University {
  final String name;
  final LatLng location;

  const University({required this.name, required this.location});
}

class UniversityLocations {
  UniversityLocations._();

  static const University assiutUniversity = University(
    name: 'Assiut University',
    location: LatLng(27.187452436450204, 31.170279713778406),
  );

  static const University assiutNationalUniversity = University(
    name: 'Assiut National University',
    location: LatLng(27.2747343680775, 31.27434549134004),
  );

  static const University badrUniversityAssiut = University(
    name: 'Badr University Assiut',
    location: LatLng(27.085447242189808, 31.069027752653657),
  );

  static const List<University> all = [
    assiutUniversity,
    assiutNationalUniversity,
    badrUniversityAssiut,
  ];

  static const University defaultUniversity = assiutUniversity;
}
