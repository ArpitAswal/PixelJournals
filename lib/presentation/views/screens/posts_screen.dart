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
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.04,
        vertical: size.height * 0.03,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SearchField(), // search field to search the posts by writing post description
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
                      padding: EdgeInsets.symmetric(vertical: 12.0),
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
      ),
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
                context.read<AuthCubit>().authInst.currentUser!.photoURL != null
                    ? NetworkImage(
                      context.read<AuthCubit>().authInst.currentUser!.photoURL!,
                    )
                    : AssetImage("assets/images/pixel_journals.png"),
          ),
        ),
        title: Text("Pixel Posts Screen"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/chat_screen');
            },
            icon: Icon(Icons.message_outlined, size: 30),
          ),
          IconButton(
            onPressed: () {
              context.read<PostsBloc>().add(Logout()); // Logout event
            },
            icon: const Icon(Icons.logout, size: 30),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/create_post_screen');
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
          side: BorderSide(color: Theme.of(context).colorScheme.secondary),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.secondary,
        child: Icon(Icons.upload),
      ),
      body: BlocBuilder<PostsBloc, PostsState>(
        builder: (context, state) {
          return (state is PostsError)
              ? Center(child: Text(state.message))
              : (state is PostsLoaded)
              ? _buildPostsList(context, state, size)
              : Center(
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
  late FocusNode _focusNode;
  late TextEditingController _searchCtrl;

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

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _searchCtrl,
      focusNode: _focusNode,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.zero,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28.0),
          borderSide: const BorderSide(color: Colors.black, width: 2.0),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28.0),
          borderSide: const BorderSide(color: Colors.black, width: 2.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28.0),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2.0,
          ),
        ),
        hintText: 'Search Posts...',
        hintStyle: TextStyle(
          color:
              _focusNode.hasFocus
                  ? Theme.of(context).colorScheme.primary
                  : Colors.black54,
        ),
        prefixIcon: Icon(
          Icons.search_outlined,
          color:
              _focusNode.hasFocus
                  ? Theme.of(context).colorScheme.primary
                  : Colors.black54,
        ),
      ),
      onTapOutside: (event) {
        _focusNode.unfocus();
      },
      onEditingComplete: () {
        _focusNode.unfocus();
        if (_searchCtrl.text.isNotEmpty) {
          // if the search field is not empty, then search the posts
          context.read<PostsBloc>().add(QueryPosts(_searchCtrl.text));
          return;
        } else {
          // if the search field is empty, then load all the posts
          context.read<PostsBloc>().add(LoadPosts());
        }
      },
    );
  }
}
