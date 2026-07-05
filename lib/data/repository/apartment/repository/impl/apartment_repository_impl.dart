import 'package:injectable/injectable.dart';
import '../../../../../core/model/ApartmentResponse.dart';
import '../../../../../core/model/apartment.dart';
import '../../data_sources/remote/apartment_remote_data_source.dart';
import '../apartment_repository.dart';

@Injectable(as: ApartmentRepository)
class ApartmentRepositoryImpl implements ApartmentRepository {
  final ApartmentRemoteDataSource remoteDataSource;
  ApartmentRepositoryImpl(this.remoteDataSource);

  @override
  Future<ApartmentResponse> addApartment(Apartment apartment, String uId) =>
      remoteDataSource.addApartment(apartment, uId);

  @override
  Future<List<ApartmentResponse>> getAllApartments() =>
      remoteDataSource.getAllApartments();

  @override
  Future<ApartmentResponse> updateApartment(Apartment apartment, String uId) =>
      remoteDataSource.updateApartment(apartment, uId);

  @override
  Future<ApartmentResponse> setApartmentVerification(
    String apartmentId,
    bool verified,
    String uId,
  ) =>
      remoteDataSource.setApartmentVerification(apartmentId, verified, uId);

  @override
  Future<void> deleteApartment(String apartmentId, String uId) =>
      remoteDataSource.deleteApartment(apartmentId, uId);

  @override
  Future<List<ApartmentResponse>> getApartmentsByOwner(String uId) =>
      remoteDataSource.getApartmentsByOwner(uId);

  @override
  Future<List<ApartmentResponse>> searchApartments(String query) =>
      remoteDataSource.searchApartments(query);
}
