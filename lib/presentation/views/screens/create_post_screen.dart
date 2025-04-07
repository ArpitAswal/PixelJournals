import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../viewmodels/bloc/create_post_bloc.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  static const String routeName = "/create_post_screen";

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  String _description = "";
  final _formKey = GlobalKey<FormState>();
  File? _image;

  void _handleListener(BuildContext context, CreatePostState state) {
    if (state is CreatePostSuccess) {
      // Check if the state is CreatePostSuccess, means the post was posted successfully
      Navigator.of(context).pop();
    } else if (state is CreatePostError) {
      // Check if the state is CreatePostError, means there was an error while posting the post
      _showErrorSnackBar(context, state.message);
    }
  }

  Widget _formWidget(BuildContext context, CreatePostState state) {
    if (state is ImageSelected) {
      // Check if the state is ImageSelected, means the image was selected successfully
      _image = state.image;
    }
    return Stack(
      alignment: Alignment.center,
      children: [
        Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 26.0, vertical: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.4,
                  child: Card(
                    margin: EdgeInsets.symmetric(horizontal: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16.0)),
                    ),
                    color: Colors.grey.shade200,
                    child:
                        (_image !=
                                null) // Check if the image is not null, means the image was selected successfully
                            ? Image.file(
                              _image!,
                              fit: BoxFit.cover,
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height * 0.5,
                            )
                            : Icon(
                              // If the image is null, show the icon
                              Icons.browse_gallery_outlined,
                              color: Colors.black,
                              size: 40,
                            ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                ElevatedButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return SafeArea(
                          child: Wrap(
                            children: <Widget>[
                              ListTile(
                                leading: const Icon(Icons.photo_library),
                                title: const Text('Photo Library'),
                                splashColor: Colors.transparent,
                                onTap: () {
                                  context.read<CreatePostBloc>().add(
                                    SelectImage("Gallery"),
                                  ); // Select image from gallery
                                  Navigator.pop(context);
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.photo_camera),
                                title: const Text('Camera'),
                                splashColor: Colors.transparent,
                                onTap: () {
                                  context.read<CreatePostBloc>().add(
                                    SelectImage("Camera"),
                                  ); // Select image from camera
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: const Text("Select Image"),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.025),
                TextFormField(
                  onSaved: (value) {
                    _description = value!;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please provide description";
                    }
                    return null;
                  },
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    decorationColor: Colors.transparent,
                    decoration: null,
                  ),
                  maxLines: null, // Allow the text field to expand vertically
                  keyboardType:
                      TextInputType.multiline, // Enable multi-line input
                  decoration: InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    hintText: 'About Image...',
                  ),
                  autocorrect: false,
                  textCapitalization: TextCapitalization.none,
                  textInputAction: TextInputAction.newline,
                ),
              ],
            ),
          ),
        ),
        if (state is CreatePostLoading)
          CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ), // Check if the state is CreatePostLoading, means the post is being posted
      ],
    );
  }

  /// Shows error message in a SnackBar
  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          content: Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          duration: Duration(seconds: 3),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_image == null) {
            // Check if the image is null, means the image was not selected, before trying to posting
            _showErrorSnackBar(context, "Please select an image!");
          } else {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              context.read<CreatePostBloc>().add(
                SubmitPost(
                  _image!,
                  _description,
                ), // Submit the post with the image and description
              );
            }
          }
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
          side: BorderSide(color: Theme.of(context).colorScheme.secondary),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.secondary,
        child: const Icon(Icons.done_outlined, weight: 24.0),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: BlocConsumer<CreatePostBloc, CreatePostState>(
            listener: _handleListener,
            builder: _formWidget,
          ),
        ),
      ),
    );
  }
}
