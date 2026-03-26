import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/cache/cubit_manger/apartment_view_model.dart';
import 'featured_estates_states.dart';

@injectable
class FeaturedEstateViewModel extends Cubit<FeaturedEstateStates> {
  final ApartmentViewModel apartmentViewModel;

  FeaturedEstateViewModel(this.apartmentViewModel) : super(FeaturedEstateInitial());

  Future<void> getFeaturedEstates() async {
    emit(FeaturedEstateLoading());
    try {
      await apartmentViewModel.getAllApartments();
      emit(FeaturedEstateSuccess(apartmentViewModel.apartmentList));
    } catch (e) {
      emit(FeaturedEstateError(e.toString()));
    }
  }
}
