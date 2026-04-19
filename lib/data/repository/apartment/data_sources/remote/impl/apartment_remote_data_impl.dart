import 'package:injectable/injectable.dart';
import '../../../../../../core/model/apartment.dart';
import '../../../../../../supabase_utils.dart';
import '../apartment_remote_data_source.dart';

@Injectable(as: ApartmentRemoteDataSource)
class ApartmentRemoteDataImpl implements ApartmentRemoteDataSource {
  @override
  Future<void> addApartment(Apartment apartment, String uId) async {
    return SupabaseUtils.addApartmentToSupabase(apartment);
  }

  @override
  Future<void> updateApartment(Apartment apartment, String uId) async {
    return SupabaseUtils.updateApartmentInSupabase(apartment);
  }

  @override
  Future<void> deleteApartment(String apartmentId, String uId) async {
    return SupabaseUtils.deleteApartmentFromSupabase(apartmentId);
  }

  @override
  Future<List<Apartment>> getAllApartments() async {
    return SupabaseUtils.getAllApartments();
  }

  @override
  Future<List<Apartment>> getApartmentsByOwner(String uId) async {
    return SupabaseUtils.getOwnerApartments(uId);
  }
}
