import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// FirebaseService class provides methods to interact with Firebase Authentication and Firestore.
class FirebaseService {
  // Firestore instance for database operations.
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Firebase Authentication instance for user authentication.
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Google Sign-In instance.
  late final GoogleSignIn _googleSignIn;

  /// Constructor to initialize Google Sign-In based on the platform (web or mobile).
  FirebaseService() {
    if (kIsWeb) {
      _googleSignIn = GoogleSignIn(
        clientId: '4072635208-rsiht1m3p9j3mjoqd1bgrdrnj5q5tf73.apps.googleusercontent.com',
      );
    } else {
      _googleSignIn = GoogleSignIn();
    }
  }

  /// Adds a new post to Firestore.
  /// 
  /// [title] - The title of the post.
  /// [content] - The content of the post.
  /// [postType] - The type of the post (e.g., blog, informative article).
  /// [imageUrl] - The URL of the image associated with the post.
  Future<void> addPost(String title, String content, String postType, String? imageUrl) async {
    await _db.collection('posts').add({
      'title': title,
      'content': content,
      'postType': postType,
      'imageUrl': imageUrl,
      'timestamp': FieldValue.serverTimestamp(),
      'keywords': title.toLowerCase().split(' ') + content.toLowerCase().split(' '),
    });
  }

  /// Returns a stream of all posts ordered by timestamp in descending order.
  Stream<QuerySnapshot> getPosts() {
    return _db.collection('posts').orderBy('timestamp', descending: true).snapshots();
  }

  /// Returns a base query for posts collection.
  Query getPostsQuery() {
    return _db.collection('posts');
  }

  /// Fetches a single post by postId from Firestore.
  /// 
  /// [postId] - The ID of the post to fetch.
  Future<DocumentSnapshot> readPost(String postId) {
    return _db.collection('posts').doc(postId).get();
  }

  /// Returns a stream of all posts without ordering.
  Stream<QuerySnapshot> readAllPosts() {
    return _db.collection('posts').snapshots();
  }

  /// Updates an existing post by postId.
  /// 
  /// [postId] - The ID of the post to update.
  /// [title] - The new title of the post.
  /// [content] - The new content of the post.
  /// [postType] - The new type of the post.
  /// [imageUrl] - The new image URL of the post.
  Future<void> updatePost(String postId, String title, String content, String postType, String? imageUrl) {
    return _db.collection('posts').doc(postId).update({
      'title': title,
      'content': content,
      'postType': postType,
      'imageUrl': imageUrl,
      'keywords': title.toLowerCase().split(' ') + content.toLowerCase().split(' '),
    });
  }

  /// Deletes a post by postId from Firestore.
  /// 
  /// [postId] - The ID of the post to delete.
  Future<void> deletePost(String postId) {
    return _db.collection('posts').doc(postId).delete();
  }

  /// Searches posts by keyword in the keywords array.
  /// 
  /// [keyword] - The keyword to search for.
  Stream<QuerySnapshot> searchPosts(String keyword) {
    return _db
        .collection('posts')
        .where('keywords', arrayContains: keyword.toLowerCase())
        .snapshots();
  }

  /// Fetches a user profile by userId from Firestore.
  /// 
  /// [userId] - The ID of the user to fetch the profile for.
  Future<DocumentSnapshot> fetchUserProfile(String userId) {
    return _db.collection('users').doc(userId).get();
  }

  /// Updates a user profile by userId.
  /// 
  /// [userId] - The ID of the user to update.
  /// [username] - The new username.
  /// [email] - The new email address.
  /// [age] - The new age.
  Future<void> updateUserProfile(String userId, String username, String email, int age) {
    return _db.collection('users').doc(userId).update({
      'username': username,
      'email': email,
      'age': age,
    });
  }

  /// Registers a new user with email, password, username, and age.
  /// 
  /// [email] - The email address of the new user.
  /// [password] - The password of the new user.
  /// [username] - The username of the new user.
  /// [age] - The age of the new user.
  Future<User?> registerUser(String email, String password, String username, int age) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;
      if (user != null) {
        await _db.collection('users').doc(user.uid).set({
          'username': username,
          'email': email,
          'age': age,
        });
      }
      return user;
    } catch (e) {
      print(e);
      return null;
    }
  }

  /// Authenticates user login with email and password.
  /// 
  /// [email] - The email address of the user.
  /// [password] - The password of the user.
  Future<User?> loginUser(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print(e);
      return null;
    }
  }

  /// Authenticates user login with Google Sign-In.
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null; // User canceled sign-in
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      print(e);
      return null;
    }
  }

  /// Logs out the current user from Firebase Auth and Google Sign-In.
  Future<void> logoutUser() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  /// Sends a password reset email to the provided email address.
  /// 
  /// [email] - The email address to send the password reset email to.
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print(e);
    }
  }

  /// Updates the password of the current user.
  /// 
  /// [newPassword] - The new password to set.
  Future<void> updatePassword(String newPassword) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
      }
    } catch (e) {
      print(e);
    }
  }
}
