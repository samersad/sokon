import '../../model/apartment.dart';

abstract class ApartmentState {}
class ApartmentInitial extends ApartmentState {}
class ApartmentLoading extends ApartmentState {}
class ApartmentLoaded extends ApartmentState {
  final List<Apartment> apartments;
  ApartmentLoaded(this.apartments);
}
class ApartmentError extends ApartmentState {
  final String message;
  ApartmentError(this.message);
}
