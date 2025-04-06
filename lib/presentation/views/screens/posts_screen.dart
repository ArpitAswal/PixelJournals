import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixel_journals/presentation/viewmodels/cubit/auth_cubit/cubit.dart';

import '../../viewmodels/bloc/posts_bloc.dart';
import '../widgets/post_item.dart';

class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});

  static const String routeName = "/posts_screen";

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  Widget _buildPostsList(BuildContext context, PostsLoaded state, Size size) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.04,
            vertical: size.height * 0.02,
          ),
          child: SearchField(),
        ), // search field to search the posts by writing post description
        Expanded(
          child:
              (state
                      .posts
                      .isEmpty) // if the posts list is empty, show a message
                  ? Center(
                    child: Text(
                      "No posts uploaded yet!",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  )
                  : ListView.builder(
                    itemCount: state.posts.length,
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.04,
                    ).copyWith(bottom: size.height * 0.05),
                    itemBuilder: (context, index) {
                      return SizedBox(
                        width: size.width,
                        height: size.height * 0.7,
                        child: PostItem(state.posts[index]),
                      );
                    },
                  ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(6.0),
          child: CircleAvatar(
            backgroundImage:
                context.read<AuthCubit>().authInst.currentUser!.photoURL !=
                        null // if the user saved profile then display it otherwise app logo
                    ? NetworkImage(
                      context.read<AuthCubit>().authInst.currentUser!.photoURL!,
                    )
                    : AssetImage("assets/images/pixel_journals.png"),
          ),
        ),
        title: LayoutBuilder(
          builder: (context, constraints) {
            return FittedBox(
              fit: BoxFit.fitWidth,
              child: Text(
                "Pixel Posts Screen",
                style: Theme.of(context).textTheme.titleLarge,
              ),
            );
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/create_post_screen');
            },
            splashColor: Colors.transparent,
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all<Color>(
                Theme.of(context).colorScheme.secondary,
              ),
              foregroundColor: WidgetStateProperty.all<Color>(
                Theme.of(context).colorScheme.primary,
              ),
              shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32.0),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
            icon: Icon(Icons.upload),
          ),
        ],
      ),
      body: BlocBuilder<PostsBloc, PostsState>(
        builder: (context, state) {
          return (state
                  is PostsError) // if there is an error, show the error message
              ? Center(child: Text(state.message))
              : (state
                  is PostsLoaded) // if the posts are loaded, show the posts list
              ? _buildPostsList(context, state, size)
              : Center(
                // if the posts are loading, show a loading indicator
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                ),
              );
        },
      ),
    );
  }
}

class SearchField extends StatefulWidget {
  const SearchField({super.key});

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late final FocusNode _focusNode;
  late final TextEditingController _searchCtrl;

  @override
  void dispose() {
    _searchCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController();
    _focusNode = FocusNode();
  }

  // Extract decoration to reduce code duplication
  OutlineInputBorder _buildBorder(
    BuildContext context, {
    bool isFocused = false,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(28.0),
      borderSide: BorderSide(
        color: isFocused ? Theme.of(context).colorScheme.primary : Colors.black,
        width: 2.0,
      ),
    );
  }

  void _handleSearch() {
    _focusNode.unfocus();
    context.read<PostsBloc>().add(
      _searchCtrl.text.isNotEmpty ? QueryPosts(_searchCtrl.text) : LoadPosts(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return TextField(
      controller: _searchCtrl,
      focusNode: _focusNode,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.zero,
        border: _buildBorder(context),
        disabledBorder: _buildBorder(context),
        focusedBorder: _buildBorder(context, isFocused: true),
        hintText: 'Search Posts...',
        hintStyle: TextStyle(
          color: _focusNode.hasFocus ? primaryColor : Colors.black54,
        ),
        prefixIcon: Icon(
          Icons.search_outlined,
          color: _focusNode.hasFocus ? primaryColor : Colors.black54,
        ),
      ),
      onTapOutside: (_) => _focusNode.unfocus(),
      onEditingComplete: _handleSearch,
    );
  }
}
