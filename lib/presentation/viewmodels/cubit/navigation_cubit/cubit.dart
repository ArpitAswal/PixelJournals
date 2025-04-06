import 'package:flutter_bloc/flutter_bloc.dart';

enum NavigationItem {
  posts,
  chats,
  users,
  settings,
} // Add other items as needed

class NavigationState {
  NavigationState({
    required this.selectedItem,
  }); // Constructor to initialize the selected item

  final NavigationItem selectedItem;
}

class NavigationCubit extends Cubit<NavigationState> {
  NavigationCubit()
    : super(
        NavigationState(selectedItem: NavigationItem.posts),
      ); // Initialize with the default selected item

  void navigate(int index) {
    switch (index) {
      case 0:
        emit(
          NavigationState(selectedItem: NavigationItem.posts),
        ); // Emit the new state with the selected item
        break;
      case 1:
        emit(
          NavigationState(selectedItem: NavigationItem.chats),
        ); // Emit the new state with the selected item
        break;
      case 2:
        emit(
          NavigationState(selectedItem: NavigationItem.users),
        ); // Emit the new state with the selected item
        break;
      case 3:
        emit(
          NavigationState(selectedItem: NavigationItem.settings),
        ); // Emit the new state with the selected item
        break;
    }
  }
}
