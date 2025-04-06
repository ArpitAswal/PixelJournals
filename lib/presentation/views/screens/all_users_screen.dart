import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../viewmodels/bloc/user_bloc.dart';
import '../widgets/users_card_item.dart';

class AllUsersScreen extends StatefulWidget {
  const AllUsersScreen({super.key});

  @override
  State<AllUsersScreen> createState() => _AllUsersScreenState();
}

class _AllUsersScreenState extends State<AllUsersScreen>
    with SingleTickerProviderStateMixin {
  late ValueNotifier<int> _selectedTabNotifier;
  late ValueNotifier<bool> _shouldAnimate;
  late TabController _tabController;

  @override
  void dispose() {
    _selectedTabNotifier.dispose(); // Dispose of the selected tab notifier
    _tabController.dispose(); // Dispose of the TabController
    _shouldAnimate.dispose(); // Dispose of the animation flag
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
    ); // Initialize the TabController with 2 tabs
    _selectedTabNotifier = ValueNotifier(
      _tabController.index,
    ); // Initialize the selected tab notifier
    _shouldAnimate = ValueNotifier(true); // Initialize the animation flag
    _tabController.addListener(() {
      // Listen for tab changes
      _selectedTabNotifier.value =
          _tabController.index; // Update the selected tab index
      if (_tabController.index == 1) {
        // If the Explore tab is selected, stop the animation
        _animateStop();
      }
    });
  }

  void _animateStop() {
    // Disable animations after a brief delay
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        _shouldAnimate.value = false; // Disable animations after 1 second
      }
    });
  }

  Widget _buildTabButton(String text, int index) {
    return ValueListenableBuilder<int>(
      // Listen for changes in the selected tab index
      valueListenable:
          _selectedTabNotifier, // Use the selected tab notifier to determine the selected index
      builder: (context, selectedIndex, child) {
        final isSelected =
            selectedIndex == index; // Check if the current tab is selected
        return ElevatedButton(
          onPressed: () => _tabController.animateTo(index),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isSelected
                    ? Theme.of(context).colorScheme.secondary
                    : Theme.of(context).colorScheme.primary,
            foregroundColor:
                isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.secondary,
            elevation: 0.0,
            padding: const EdgeInsets.all(8.0),
            minimumSize: const Size(120, 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
              side: BorderSide(
                color:
                    isSelected
                        ? Colors.red
                        : Theme.of(context).colorScheme.secondary,
                width: 2,
              ),
            ),
          ),
          child: Text(text),
        );
      },
    );
  }

  Widget _buildUserList(
    BuildContext context,
    List<dynamic> users,
    UserState state,
    bool isFollowing,
  ) {
    if (users.isEmpty) {
      return Center(
        child: Text(
          isFollowing ? "Not following anyone yet" : "No new users to follow",
        ),
      );
    }

    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        if (!_shouldAnimate.value) {
          // If animations are disabled, return the user card without animation
          return _buildUserGestureCard(user, isFollowing);
        }

        // If animations are enabled, use SlideInRight or SlideInLeft based on the index
        return (index % 2 == 0)
            ? SlideInRight(
              key: ValueKey(
                '${user.userId}_right',
              ), // Use a value key for each user card to avoid animation conflicts
              duration: const Duration(milliseconds: 800),
              child: _buildUserGestureCard(user, isFollowing),
            )
            : SlideInLeft(
              key: ValueKey(
                '${user.userId}_left',
              ), // Use a value key for each user card to avoid animation conflicts
              duration: const Duration(milliseconds: 800),
              child: _buildUserGestureCard(user, isFollowing),
            );
      },
    );
  }

  Widget _buildUserGestureCard(dynamic user, bool isFollowing) {
    return GestureDetector(
      onTap:
          () => Navigator.pushNamed(
            context,
            '/userPostsScreen',
            arguments: user.userId,
          ),
      child: UserCard(
        user: user,
        isFollowing: isFollowing,
        onFollowToggle:
            () => context.read<UserBloc>().add(
              ToggleFollowUser(user),
            ), // Toggle follow status when the follow button tapped on user card.
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pixel Journals Users"),
        bottom: TabBar(
          indicatorColor: Colors.white,
          controller: _tabController,
          tabs: [
            Tab(child: _buildTabButton("Following", 0)),
            Tab(child: _buildTabButton("Explore", 1)),
          ],
        ),
      ),
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          if (state is UserLoaded) {
            // When users are loaded, display the user lists
            final followedUsers =
                state.users
                    .where(
                      (user) => state.followUsers
                          .map((e) => e.userId)
                          .contains(user.userId),
                    )
                    .toList(); // Get the list of followed users

            final unfollowedUsers =
                state.users
                    .where(
                      (user) =>
                          !state.followUsers
                              .map((e) => e.userId)
                              .contains(user.userId),
                    )
                    .toList(); // Get the list of unfollowed users

            return TabBarView(
              controller: _tabController,
              children: [
                _buildUserList(
                  context,
                  followedUsers,
                  state,
                  true,
                ), // Display the list of followed users
                _buildUserList(
                  context,
                  unfollowedUsers,
                  state,
                  false,
                ), // Display the list of unfollowed users
              ],
            );
          } else if (state is UserError) {
            // Show error message if there is an error loading users
            return Center(child: Text(state.message));
          }

          return const Center(
            child: CircularProgressIndicator(),
          ); // Show loading indicator while users are being loaded, means the current state is in loading state
        },
      ),
    );
  }
}
