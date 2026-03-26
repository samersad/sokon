import '../../model/my_user.dart';

abstract class UserState {}
class UserInitial extends UserState {}
class UserUpdated extends UserState {
  final MyUser? user;
  UserUpdated(this.user);
}