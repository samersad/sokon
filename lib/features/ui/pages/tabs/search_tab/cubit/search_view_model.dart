import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../../../core/model/apartment.dart';
import '../../../../../../data/repository/apartment/repository/apartment_repository.dart';
import 'search_states.dart';

@injectable
class SearchViewModel extends Cubit<SearchStates> {
  final ApartmentRepository apartmentRepository;
  SearchViewModel(this.apartmentRepository) : super(SearchInitial());

  List<Apartment> _allApartments = [];
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
      if (_allApartments.isEmpty) {
        _allApartments = await apartmentRepository.getAllApartments();
      }

      final results = _allApartments.where((apartment) {
        final name = apartment.name?.toLowerCase() ?? "";
        final description = apartment.description?.toLowerCase() ?? "";
        final address = apartment.address?.toLowerCase() ?? "";
        final city = apartment.city?.toLowerCase() ?? "";
        final district = apartment.district?.toLowerCase() ?? "";
        final floor = apartment.floor?.toString() ?? "";
        final searchLower = query.toLowerCase();

        return name.contains(searchLower) ||
            description.contains(searchLower) ||
            address.contains(searchLower) ||
            city.contains(searchLower) ||
            district.contains(searchLower) ||
            floor.contains(searchLower);
      }).toList();

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
    double? minPrice,
    double? maxPrice,
    int? bedrooms,
  }) async {
    emit(SearchLoading());
    try {
      if (_allApartments.isEmpty) {
        _allApartments = await apartmentRepository.getAllApartments();
      }

      final results = _allApartments.where((apartment) {
        bool matches = true;
        if (minPrice != null && (apartment.price ?? 0) < minPrice) matches = false;
        if (maxPrice != null && (apartment.price ?? 0) > maxPrice) matches = false;
        if (bedrooms != null && apartment.bedrooms != bedrooms) matches = false;
        return matches;
      }).toList();

      emit(SearchLoaded(results));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }
}
