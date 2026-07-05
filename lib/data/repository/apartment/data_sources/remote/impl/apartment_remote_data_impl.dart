import 'package:injectable/injectable.dart';
import 'package:sokon/api/api_service .dart';
import '../../../../../../core/model/ApartmentResponse.dart';
import '../../../../../../core/model/apartment.dart';
import '../apartment_remote_data_source.dart';

@Injectable(as: ApartmentRemoteDataSource)
class ApartmentRemoteDataImpl implements ApartmentRemoteDataSource {
  final ApiService _apiService = ApiService();

  @override
  Future<ApartmentResponse> addApartment(Apartment apartment, String uId) async {
    return _apiService.addApartment(apartment);
  }

  @override
  Future<ApartmentResponse> updateApartment(Apartment apartment, String uId) async {
    return _apiService.updateApartment(apartment);
  }

  @override
  Future<ApartmentResponse> setApartmentVerification(
    String apartmentId,
    bool verified,
    String uId,
  ) async {
    return _apiService.setApartmentVerification(
      apartmentId: apartmentId,
      verified: verified,
    );
  }

  @override
  Future<void> deleteApartment(String apartmentId, String uId) async {
    await _apiService.deleteApartment(apartmentId);
  }

  @override
  Future<List<ApartmentResponse>> getAllApartments() async {
    return _apiService.getAllApartments();
  }

  @override
  Future<List<ApartmentResponse>> getApartmentsByOwner(String uId) async {
    return _apiService.getApartmentsByOwner(uId);
  }

  @override
  Future<List<ApartmentResponse>> searchApartments(String query) async {
    return _apiService.searchApartments(query);
  }

  @override
  Future<List<ApartmentResponse>> filterApartments({
    String? type,
    String? district,
    String? gender,
    double? minPrice,
    double? maxPrice,
    int? bedrooms,
  }) async {
    return _apiService.filterApartments(
      type: type,
      district: district,
      gender: gender,
      minPrice: minPrice,
      maxPrice: maxPrice,
      bedrooms: bedrooms,
    );
  }
}
