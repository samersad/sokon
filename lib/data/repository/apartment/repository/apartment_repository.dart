import '../../../../../core/model/apartment.dart';

abstract class ApartmentRepository {
  Future<void> addApartment(Apartment apartment, String uId);
  Future<List<Apartment>> getAllApartments();
}
