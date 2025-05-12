import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../firebase_service.dart';
import 'package:get_it/get_it.dart';

// InformativeArticlePage allows viewing a specific informative article and using text-to-speech to read the content
class InformativeArticlePage extends StatefulWidget {
  final String postId; // ID of the article to be viewed

  InformativeArticlePage({required this.postId}); // Constructor requiring postId

  @override
  State<InformativeArticlePage> createState() => _InformativeArticlePageState();
}

class _InformativeArticlePageState extends State<InformativeArticlePage> {
  late FlutterTts flutterTts; // Text-to-Speech instance
  bool isPlaying = false; // Indicates if TTS is currently playing

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts(); // Initialize TTS
    flutterTts.setCompletionHandler(() {
      setState(() {
        isPlaying = false; // Set playing state to false on completion
      });
    });
  }

  @override
  void dispose() {
    flutterTts.stop(); // Stop TTS on widget disposal
    super.dispose();
  }

  // Function to start speaking the given text
  Future<void> _speak(String text) async {
    await flutterTts.speak(text);
    setState(() {
      isPlaying = true; // Set playing state to true
    });
  }

  // Function to stop speaking
  Future<void> _stop() async {
    await flutterTts.stop();
    setState(() {
      isPlaying = false; // Set playing state to false
    });
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseService fbService = GetIt.instance<FirebaseService>(); // Get Firebase service instance
    bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait; // Check if the device is in portrait mode

    return Scaffold(
      appBar: AppBar(
        title: Text('Informative Article'), // App bar title
        backgroundColor: Colors.green, // App bar background color
        foregroundColor: Colors.white, // App bar foreground color
        actions: [
          IconButton(
            icon: Icon(isPlaying ? Icons.stop : Icons.play_arrow),
            onPressed: () async {
              if (isPlaying) {
                await _stop();
              } else {
                final post = await fbService.readPost(widget.postId);
                if (post.exists) {
                  final data = post.data() as Map<String, dynamic>;
                  await _speak(data['content']); // Speak the post content
                }
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: fbService.readPost(widget.postId), // Fetch the article
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // Show loading indicator while fetching data
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Article not found.')); // Show message if article is not found
          }

          var post = snapshot.data!.data() as Map<String, dynamic>; // Extract post data

          return isPortrait
              ? _buildPortraitLayout(post, context) // Build portrait layout
              : _buildLandscapeLayout(post, context); // Build landscape layout
        },
      ),
    );
  }

  // Function to build portrait layout
  Widget _buildPortraitLayout(Map<String, dynamic> post, BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _buildPostContent(post, context), // Build post content
      ),
    );
  }

  // Function to build landscape layout
  Widget _buildLandscapeLayout(Map<String, dynamic> post, BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _buildPostContent(post, context).sublist(0, 2), // Title and optional image
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _buildPostContent(post, context).sublist(2), // Content text
            ),
          ),
        ),
      ],
    );
  }

  // Function to build post content widgets
  List<Widget> _buildPostContent(Map<String, dynamic> post, BuildContext context) {
    return [
      Text(
        post['title'], // Display post title
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(height: 16),
      if (post['imageUrl'] != null) // If post has an image URL
        GestureDetector(
          onTap: () => _showFullImage(context, post['imageUrl']), // Show full image on tap
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.network(
                post['imageUrl'],
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Center(child: Text('Error loading image')); // Show error if image loading fails
                },
              ),
            ),
          ),
        ),
      SizedBox(height: 16),
      Text(
        post['content'], // Display post content
        style: TextStyle(fontSize: 16),
      ),
    ];
  }

  // Function to show full image in a dialog
  void _showFullImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            children: [
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Center(child: Text('Error loading image')); // Show error if image loading fails
                    },
                  ),
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(), // Close dialog on tap
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.black54,
                    child: Icon(Icons.close, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
