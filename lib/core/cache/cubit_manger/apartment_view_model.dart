import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:sokon/core/model/apartment.dart';
import 'package:sokon/data/repository/apartment/repository/apartment_repository.dart';
import 'apartment_states.dart';

@lazySingleton
class ApartmentViewModel extends Cubit<ApartmentState> {
  final ApartmentRepository apartmentRepository;
  ApartmentViewModel(this.apartmentRepository) : super(ApartmentInitial());

  List<Apartment> apartmentList = [];

  Future<void> getAllApartmentForOwner(String uId) async {
    emit(ApartmentLoading());
    try {
      apartmentList = await apartmentRepository.getApartmentsByOwner(uId);
      emit(ApartmentLoaded(apartmentList));
    } catch (e) {
      emit(ApartmentError(e.toString()));
    }
  }

  Future<void> getAllApartments() async {
    emit(ApartmentLoading());
    try {
      apartmentList = await apartmentRepository.getAllApartments();
      emit(ApartmentLoaded(apartmentList));
    } catch (e) {
      emit(ApartmentError(e.toString()));
    }
  }

  Future<void> deleteApartment(String apartmentId, String uId) async {
    try {
      await apartmentRepository.deleteApartment(apartmentId, uId);
      apartmentList.removeWhere((element) => element.id == apartmentId);
      emit(ApartmentLoaded(List.from(apartmentList)));
    } catch (e) {
      emit(ApartmentError(e.toString()));
    }
  }

  Future<void> updateApartment(Apartment apartment, String uId) async {
    try {
      await apartmentRepository.updateApartment(apartment, uId);
      int index = apartmentList.indexWhere((element) => element.id == apartment.id);
      if (index != -1) {
        apartmentList[index] = apartment;
      }
      emit(ApartmentLoaded(List.from(apartmentList)));
    } catch (e) {
      emit(ApartmentError(e.toString()));
    }
  }
}
