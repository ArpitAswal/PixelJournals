import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../data/repositories/post_repository.dart';

//Create Post Events
abstract class CreatePostEvent {}

class SelectImage extends CreatePostEvent {
  // Event to select image from camera or gallery
  SelectImage(this.source) : image = null; // Initialize image to null

  XFile? image;
  final String source;
}

class SubmitPost extends CreatePostEvent {
  // Event to submit post
  SubmitPost(this.image, this.description);

  final String description;
  final File image;
}

//States
abstract class CreatePostState {}

class CreatePostInitial
    extends CreatePostState {} // Initial state of the post creation process

class ImageSelected extends CreatePostState {
  // State when an image is selected
  ImageSelected(this.image);

  final File image;
}

class CreatePostLoading
    extends CreatePostState {} // State when the post is being created

class CreatePostSuccess
    extends CreatePostState {} // State when the post is created successfully

class CreatePostError extends CreatePostState {
  // State when there is an error in post creation
  CreatePostError(this.message);

  final String message;
}

class CreatePostBloc extends Bloc<CreatePostEvent, CreatePostState> {
  CreatePostBloc(this._postRepository) : super(CreatePostInitial()) {
    // Constructor to initialize the post repository and set the initial state
    on<SubmitPost>((event, emit) async {
      emit(
        CreatePostLoading(),
      ); // Emit loading state when the post is being created
      try {
        await _postRepository.createPost(event.image, event.description);
        emit(
          CreatePostSuccess(),
        ); // Emit success state when the post is created successfully
      } catch (e) {
        emit(
          CreatePostError(e.toString()),
        ); // Emit error state when there is an error in post creation
      }
    });

    on<SelectImage>((event, emit) async {
      // Event to select image from camera or gallery
      if (event.source == 'Camera') {
        var cameraAccess = await Permission.camera.status;
        if (!cameraAccess.isGranted) {
          // Check if camera access is granted
          await Permission.camera.request();
        }
        if (cameraAccess.isGranted) {
          event.image = await _postRepository.pickImage(
            ImageSource.camera,
          ); // Pick image from camera
        }
      } else {
        var galleryAccess = await Permission.storage.status;
        if (!galleryAccess.isGranted) {
          // Check if gallery access is granted
          await Permission.storage.request();
        }
        if (galleryAccess.isGranted) {
          event.image = await _postRepository.pickImage(
            ImageSource.gallery,
          ); // Pick image from gallery
        }
      }
      if (event.image != null) {
        // Check if the image is not null, means the image was selected successfully
        emit(ImageSelected(File(event.image!.path)));
      }
    });
  }

  final PostsRepository _postRepository;
}
