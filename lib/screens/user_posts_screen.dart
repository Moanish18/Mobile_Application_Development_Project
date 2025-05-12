import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../firebase_service.dart'; // Import your Firebase service class
import 'update_post_screen.dart'; // Import the update post screen where needed

class UserPostsPage extends StatelessWidget {
  final FirebaseService fbService = GetIt.instance<FirebaseService>(); // Instance of FirebaseService using GetIt

  @override
  Widget build(BuildContext context) {
    bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      appBar: AppBar(
        title: Text('My Posts'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: fbService.getPosts(), // Stream to listen for changes in posts collection
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // Display loading indicator while fetching data
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}')); // Display error message if fetching data fails
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No posts yet')); // Display message if there are no posts
          }

          final posts = snapshot.data!.docs; // List of documents from the snapshot

          return isPortrait
              ? _buildPortraitLayout(context, posts) // Build portrait layout if device is in portrait orientation
              : _buildLandscapeLayout(context, posts); // Build landscape layout if device is in landscape orientation
        },
      ),
    );
  }

  // Build portrait layout with ListView
  Widget _buildPortraitLayout(BuildContext context, List<QueryDocumentSnapshot> posts) {
    return ListView.builder(
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return Card(
          child: ListTile(
            title: Text(
              post['title'],
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              post['content'],
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text(_getPostTypeDisplayName(post['postType'])), // Display post type
            onTap: () {
              _navigateToUpdatePost(context, post.id); // Navigate to update post screen on tap
            },
          ),
        );
      },
    );
  }

  // Build landscape layout with GridView
  Widget _buildLandscapeLayout(BuildContext context, List<QueryDocumentSnapshot> posts) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return Card(
          child: ListTile(
            title: Text(
              post['title'],
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              post['content'],
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text(_getPostTypeDisplayName(post['postType'])), // Display post type
            onTap: () {
              _navigateToUpdatePost(context, post.id); // Navigate to update post screen on tap
            },
          ),
        );
      },
    );
  }

  // Navigate to update post screen
  void _navigateToUpdatePost(BuildContext context, String postId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdatePostPage(postId: postId), // Pass postId to UpdatePostPage
      ),
    );
  }

  // Convert postType to display name
  String _getPostTypeDisplayName(String postType) {
    switch (postType) {
      case 'informativeArticle':
        return 'Informative Article';
      case 'blog':
        return 'Blog';
      default:
        return 'Unknown';
    }
  }
}
