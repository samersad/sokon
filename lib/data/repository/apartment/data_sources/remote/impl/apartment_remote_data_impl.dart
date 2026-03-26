import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import '../../../../../../core/model/apartment.dart';
import '../../../../../../firebase_utils.dart';
import '../apartment_remote_data_source.dart';

@Injectable(as: ApartmentRemoteDataSource)
class ApartmentRemoteDataImpl implements ApartmentRemoteDataSource {
  @override
  Future<void> addApartment(Apartment apartment, String uId) async {
    return FireBaseUtils.addApartmentToFirestore(apartment, uId);
  }

  @override
  Future<void> updateApartment(Apartment apartment, String uId) async {
    return FireBaseUtils.updateApartmentInFirestore(apartment, uId);
  }

  @override
  Future<void> deleteApartment(String apartmentId, String uId) async {
    return FireBaseUtils.deleteApartmentFromFirestore(apartmentId, uId);
  }

  @override
  Future<List<Apartment>> getAllApartments() async {
    var querySnapshot = await FireBaseUtils.getAllApartmentsCollections().get();
    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }

  @override
  Future<List<Apartment>> getApartmentsByOwner(String uId) async {
    var querySnapshot = await FireBaseUtils.getApartmentCollections(uId).get();
    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }
}
