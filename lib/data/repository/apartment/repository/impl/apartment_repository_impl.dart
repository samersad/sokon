import 'package:injectable/injectable.dart';
import '../../../../../core/model/apartment.dart';
import '../../data_sources/remote/apartment_remote_data_source.dart';
import '../apartment_repository.dart';

@Injectable(as: ApartmentRepository)
class ApartmentRepositoryImpl implements ApartmentRepository {
  final ApartmentRemoteDataSource remoteDataSource;
  ApartmentRepositoryImpl(this.remoteDataSource);

  @override
  Future<void> addApartment(Apartment apartment, String uId) =>
      remoteDataSource.addApartment(apartment, uId);

  @override
  Future<List<Apartment>> getAllApartments() =>
      remoteDataSource.getAllApartments();
}
