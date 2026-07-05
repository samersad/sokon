import 'ApartmentResponse.dart';

class DistrictSummary {
  final String district;
  final List<ApartmentResponse> apartments;

  const DistrictSummary({
    required this.district,
    required this.apartments,
  });

  int get apartmentCount => apartments.length;
}

List<DistrictSummary> buildDistrictSummaries(List<ApartmentResponse> apartments) {
  final Map<String, List<ApartmentResponse>> groupedApartments = {};

  for (final apartment in apartments) {
    final district = _resolveDistrictName(apartment.district);
    groupedApartments.putIfAbsent(district, () => <ApartmentResponse>[]).add(apartment);
  }

  final summaries = groupedApartments.entries
      .map(
        (entry) => DistrictSummary(
          district: entry.key,
          apartments: List<ApartmentResponse>.unmodifiable(entry.value),
        ),
      )
      .toList();

  summaries.sort((a, b) {
    final countComparison = b.apartmentCount.compareTo(a.apartmentCount);
    if (countComparison != 0) {
      return countComparison;
    }
    return a.district.toLowerCase().compareTo(b.district.toLowerCase());
  });

  return summaries;
}

String _resolveDistrictName(String? district) {
  final resolved = district?.trim();
  if (resolved == null || resolved.isEmpty) {
    return "Unknown district";
  }
  return resolved;
}
