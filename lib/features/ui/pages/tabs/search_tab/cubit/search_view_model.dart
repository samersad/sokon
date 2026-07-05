import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../../../core/model/ApartmentResponse.dart';
import '../../../../../../data/repository/apartment/repository/apartment_repository.dart';
import 'search_states.dart';

@injectable
class SearchViewModel extends Cubit<SearchStates> {
  final ApartmentRepository apartmentRepository;
  SearchViewModel(this.apartmentRepository) : super(SearchInitial());

  List<ApartmentResponse> _allApartments = [];
  List<String> _recentSearches = [];

  void getAllApartments() async {
    emit(SearchLoading());
    try {
      _allApartments = await apartmentRepository.getAllApartments();
      emit(SearchLoaded(_allApartments));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }

  void search(String query) async {
    if (query.isEmpty) {
      emit(SearchLoaded(_allApartments));
      return;
    }

    emit(SearchLoading());
    try {
      final results = await apartmentRepository.searchApartments(query);

      if (results.isNotEmpty && !_recentSearches.contains(query)) {
        _recentSearches.insert(0, query);
        if (_recentSearches.length > 5) _recentSearches.removeLast();
      }

      emit(SearchLoaded(results));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }

  void filter({
    String? type,
    String? district,
    String? gender,
    double? minPrice,
    double? maxPrice,
    int? bedrooms,
  }) async {
    emit(SearchLoading());
    try {
      final results = await apartmentRepository.filterApartments(
        type: type,
        district: district,
        gender: gender,
        minPrice: minPrice,
        maxPrice: maxPrice,
        bedrooms: bedrooms,
      );
      emit(SearchLoaded(results));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }
}
