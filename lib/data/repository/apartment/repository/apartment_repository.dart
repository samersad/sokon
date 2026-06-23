import '../../../../../core/model/apartment.dart';
import '../../../../../core/model/ApartmentResponse.dart';

abstract class ApartmentRepository {
  Future<ApartmentResponse> addApartment(Apartment apartment, String uId);
  Future<ApartmentResponse> updateApartment(Apartment apartment, String uId);
  Future<ApartmentResponse> setApartmentVerification(
    String apartmentId,
    bool verified,
    String uId,
  );
  Future<void> deleteApartment(String apartmentId, String uId);
  Future<List<ApartmentResponse>> getAllApartments();
  Future<List<ApartmentResponse>> getApartmentsByOwner(String uId);
  Future<List<ApartmentResponse>> searchApartments(String query);
}
