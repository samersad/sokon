import '../../../../../core/model/ApartmentResponse.dart';

abstract class FeaturedEstateStates {}

class FeaturedEstateInitial extends FeaturedEstateStates {}

class FeaturedEstateLoading extends FeaturedEstateStates {}

class FeaturedEstateSuccess extends FeaturedEstateStates {
  final List<ApartmentResponse> apartments;
  FeaturedEstateSuccess(this.apartments);
}

class FeaturedEstateError extends FeaturedEstateStates {
  final String message;
  FeaturedEstateError(this.message);
}
