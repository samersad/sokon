import '../../../../../core/model/apartment.dart';

abstract class ApartmentRemoteDataSource {
  Future<void> addApartment(Apartment apartment, String uId);
  Future<List<Apartment>> getAllApartments();
}
