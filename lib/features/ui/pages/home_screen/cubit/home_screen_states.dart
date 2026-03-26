abstract class HomeScreenStates {}

class HomeScreenInitial extends HomeScreenStates {}

class ChangeTabIndexState extends HomeScreenStates {
  final int index;
  ChangeTabIndexState(this.index);
}
