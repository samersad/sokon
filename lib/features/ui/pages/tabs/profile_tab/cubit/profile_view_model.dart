import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../../../core/cache/cubit_manger/user_view_model.dart';
import '../../../../../../data/repository/auth/repository/auth_repository.dart';
import 'profile_states.dart';

@injectable
class ProfileViewModel extends Cubit<ProfileStates> {
  final AuthRepository authRepository;
  final UserViewModel userViewModel;

  ProfileViewModel(this.authRepository, this.userViewModel)
      : super(ProfileInitial());

  Future<void> logout() async {
    emit(ProfileLoading());
    try {
      await authRepository.signOut();
      userViewModel.updateUser(null);
      emit(ProfileLogoutSuccess());
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}
