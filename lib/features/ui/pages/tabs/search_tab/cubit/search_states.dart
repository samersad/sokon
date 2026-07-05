import '../../../../../../core/model/ApartmentResponse.dart';

abstract class SearchStates {}

class SearchInitial extends SearchStates {
  final List<String> recentSearches;
  SearchInitial({this.recentSearches = const []});
}

class SearchLoading extends SearchStates {}

class SearchLoaded extends SearchStates {
  final List<ApartmentResponse> results;
  SearchLoaded(this.results);
}

class SearchError extends SearchStates {
  final String message;
  SearchError(this.message);
}
