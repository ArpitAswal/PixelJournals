import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../data/models/post_model.dart';

class UserDetailScreen extends StatelessWidget {
  final String userId;
  const UserDetailScreen({super.key, required this.userId});

  static const String routeName = '/userDetailScreen';

  @override
  Widget build(BuildContext context) {
    final postsRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(userId)
        .collection('userPosts')
        .orderBy('postTimeStamp', descending: true);

    return Scaffold(
      appBar: AppBar(title: const Text('User Posts')),
      body: StreamBuilder<QuerySnapshot>(
        stream: postsRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final posts =
              snapshot.data!.docs
                  .map(
                    (doc) =>
                        PostModel.fromMap(doc.data() as Map<String, dynamic>),
                  )
                  .toList();

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return Card(
                margin: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.network(post.postUrl),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(post.postDescription),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
