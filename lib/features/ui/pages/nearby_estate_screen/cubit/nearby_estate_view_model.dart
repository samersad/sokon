import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/cache/cubit_manger/apartment_view_model.dart';
import 'nearby_estate_states.dart';

@injectable
class NearbyEstateViewModel extends Cubit<NearbyEstateStates> {
  final ApartmentViewModel apartmentViewModel;
  
  NearbyEstateViewModel(this.apartmentViewModel) : super(NearbyEstateInitial());

  Future<void> getNearbyEstates() async {
    emit(NearbyEstateLoading());
    try {
      await apartmentViewModel.getAllApartments();
      emit(NearbyEstateSuccess(apartmentViewModel.apartmentList));
    } catch (e) {
      emit(NearbyEstateError(e.toString()));
    }
  }
}
