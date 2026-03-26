import '../../../../../core/model/apartment.dart';

abstract class ApartmentRemoteDataSource {
  Future<void> addApartment(Apartment apartment, String uId);
  Future<void> updateApartment(Apartment apartment, String uId);
  Future<void> deleteApartment(String apartmentId, String uId);
  Future<List<Apartment>> getAllApartments();
  Future<List<Apartment>> getApartmentsByOwner(String uId);
}
