abstract class AddApartmentStates {}

class AddApartmentInitial extends AddApartmentStates {}

class AddApartmentLoading extends AddApartmentStates {}

class AddApartmentSuccess extends AddApartmentStates {}

class AddApartmentError extends AddApartmentStates {
  final String message;
  final bool requiresPhoneVerification;

  AddApartmentError(this.message, {this.requiresPhoneVerification = false});
}

class AddApartmentProgress extends AddApartmentStates {
  final String message;
  AddApartmentProgress(this.message);
}

class AddApartmentUpdateUI extends AddApartmentStates {}
