import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../../../supabase_utils.dart';
import 'my_bookings_states.dart';

@injectable
class MyBookingsViewModel extends Cubit<MyBookingsStates> {
  MyBookingsViewModel() : super(MyBookingsInitial());

  StreamSubscription? _bookingsSubscription;

  Future<void> getMyBookings(String userId) async {
    emit(MyBookingsLoading());
    await _bookingsSubscription?.cancel();
    try {
      _bookingsSubscription = SupabaseUtils.getBookingsStream(userId).listen(
        (bookings) {
          emit(MyBookingsSuccess(bookings));
        },
        onError: (error) {
          emit(MyBookingsError(error.toString()));
        },
      );
    } catch (e) {
      emit(MyBookingsError(e.toString()));
    }
  }

  @override
  Future<void> close() async {
    await _bookingsSubscription?.cancel();
    return super.close();
  }
}
