import 'package:flutter/material.dart';

import '../../../data/models/user_model.dart';

class UserCard extends StatelessWidget {
  const UserCard({
    super.key,
    required this.user,
    required this.isFollowing,
    required this.onFollowToggle,
  });

  final bool isFollowing;
  final VoidCallback onFollowToggle;
  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            (user.userProfile != null)
                ? CircleAvatar(backgroundImage: NetworkImage(user.userProfile!))
                : CircleAvatar(child: Icon(Icons.person)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                user.userName,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            ElevatedButton(
              style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                minimumSize: WidgetStateProperty.all(
                  Size(MediaQuery.of(context).size.width * 0.3, 40),
                ),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28.0),
                  ),
                ),
              ),
              onPressed: onFollowToggle,
              child: Text(isFollowing ? 'Unfollow' : 'Follow'),
            ),
          ],
        ),
      ),
    );
  }
}
