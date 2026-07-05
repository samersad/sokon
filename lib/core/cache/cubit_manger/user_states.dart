import '../../model/RegisterResponse.dart';

abstract class UserState {}
class UserInitial extends UserState {}
class UserUpdated extends UserState {
  final RegisterUser? user;
  UserUpdated(this.user);
}
