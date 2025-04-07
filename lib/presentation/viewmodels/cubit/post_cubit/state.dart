import 'package:equatable/equatable.dart';

// Equatable is used to compare the state objects
class PostDetailState extends Equatable {
  const PostDetailState({this.isExpand = false, this.isLiked = false});

  final bool isExpand;
  final bool isLiked;

  @override
  List<Object> get props => [isExpand, isLiked]; // List of properties to compare

  // copyWith is used to create a new instance of the state with updated values
  PostDetailState copyWith({bool? isExpand, bool? isLiked}) {
    return PostDetailState(
      isExpand: isExpand ?? this.isExpand,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}
