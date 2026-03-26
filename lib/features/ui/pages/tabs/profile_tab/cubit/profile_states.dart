abstract class ProfileStates {}

class ProfileInitial extends ProfileStates {}

class ProfileLoading extends ProfileStates {}

class ProfileLogoutSuccess extends ProfileStates {}

class ProfileError extends ProfileStates {
  final String message;
  ProfileError(this.message);
}
