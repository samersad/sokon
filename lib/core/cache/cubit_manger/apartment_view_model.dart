import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sokon/core/model/apartment.dart';
import '../../../firebase_utils.dart';
import 'apartment_states.dart';


class ApartmentViewModel extends Cubit<ApartmentState> {
  ApartmentViewModel() : super(ApartmentInitial());

  List<Apartment> apartmentList = [];

  Future<void> getAllApartmentForOwner(String uId) async {
    emit(ApartmentLoading());
    try {
      var querySnapshot = await FireBaseUtils.getApartmentCollections(uId).get();
      apartmentList = querySnapshot.docs.map((doc) => doc.data()).toList();
      emit(ApartmentLoaded(apartmentList));
    } catch (e) {
      emit(ApartmentError(e.toString()));
    }
  }

  Future<void> getAllApartments() async {
    emit(ApartmentLoading());
    try {
      var querySnapshot = await FireBaseUtils.getAllApartmentsCollections().get();
      apartmentList = querySnapshot.docs.map((doc) => doc.data()).toList();
      emit(ApartmentLoaded(apartmentList));
    } catch (e) {
      emit(ApartmentError(e.toString()));
    }
  }
}
