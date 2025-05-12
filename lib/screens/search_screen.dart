import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../firebase_service.dart';
import 'blog_view_page.dart';
import 'informative_article_page.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final FirebaseService fbService = GetIt.instance<FirebaseService>();
  final TextEditingController _searchController = TextEditingController();
  String? _selectedPostType;
  String _sortField = 'timestamp';
  bool _sortAscending = true;

  SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _statusMessage = '';
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchTyped);
    _initSpeech();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchTyped);
    _searchController.dispose();
    super.dispose();
  }

  // Initialize speech recognition
  Future<void> _initSpeech() async {
    final status = await Permission.microphone.request();
    if (status == PermissionStatus.granted) {
      _speechEnabled = await _speechToText.initialize(
        onError: (val) => setState(() => _errorMessage = 'Speech recognition error: ${val.errorMsg}'),
        onStatus: (val) => setState(() => _statusMessage = 'Speech recognition status: $val'),
      );
      setState(() {});
    } else {
      setState(() {
        _errorMessage = 'Microphone permission not granted';
      });
    }
  }

  // Start listening for speech input
  void _startListening() async {
    if (_speechEnabled) {
      await _speechToText.listen(onResult: _onSpeechResult);
      setState(() {});
    } else {
      setState(() {
        _errorMessage = 'Speech recognition not enabled';
      });
    }
  }

  // Stop listening for speech input
  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  // Handle speech recognition result
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _searchController.text = result.recognizedWords;
    });
  }

  // Handle search text input change
  void _onSearchTyped() {
    setState(() {});
  }

  // Clear filters
  void _clearFilters() {
    setState(() {
      _selectedPostType = null;
    });
  }

  // Get the stream of posts based on search criteria
  Stream<QuerySnapshot> _getPostStream() {
    Query query = fbService.getPostsQuery();

    if (_selectedPostType != null) {
      query = query.where('postType', isEqualTo: _selectedPostType);
    }

    if (_searchController.text.isNotEmpty) {
      final searchText = _searchController.text.trim().toLowerCase();
      query = query.where('keywords', arrayContains: searchText);
    }

    return query.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      appBar: AppBar(
        title: Text('Search Posts'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: Icon(Icons.sort),
            onPressed: _showSortDialog,
          ),
        ],
      ),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: isPortrait ? _buildPortraitLayout(context) : _buildLandscapeLayout(context),
              ),
            ),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            if (_statusMessage.isNotEmpty && _errorMessage.isEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _statusMessage,
                  style: TextStyle(color: Colors.green),
                ),
              ),
            Container(
              height: MediaQuery.of(context).size.height - kToolbarHeight - 200, // Adjust this value as needed
              child: StreamBuilder<QuerySnapshot>(
                stream: _getPostStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No posts found.'));
                  }

                  var sortedDocs = snapshot.data!.docs;
                  sortedDocs.sort((a, b) {
                    var aValue = a[_sortField];
                    var bValue = b[_sortField];
                    if (aValue is Timestamp && bValue is Timestamp) {
                      return _sortAscending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
                    } else if (aValue is String && bValue is String) {
                      return _sortAscending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
                    } else {
                      return 0;
                    }
                  });

                  return ListView.builder(
                    itemCount: sortedDocs.length,
                    itemBuilder: (context, index) {
                      var post = sortedDocs[index];
                      return ListTile(
                        title: Text(post['title']),
                        subtitle: Text(
                          post['content'],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () {
                          var postType = post['postType'];
                          if (postType == 'blog') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BlogViewPage(postId: post.id),
                              ),
                            );
                          } else if (postType == 'informativeArticle') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => InformativeArticlePage(postId: post.id),
                              ),
                            );
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPortraitLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Enter keyword...',
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16.0),
            ),
          ),
        ),
        IconButton(
          icon: Icon(
            _speechToText.isNotListening ? Icons.mic : Icons.mic_off,
            color: _speechToText.isNotListening ? Colors.green : Colors.red,
          ),
          onPressed: _speechToText.isNotListening ? _startListening : _stopListening,
        ),
        Container(
          margin: EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () => setState(() {}),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: Text('Search', style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }

  Widget _buildLandscapeLayout(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Enter keyword...',
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16.0),
            ),
          ),
        ),
        IconButton(
          icon: Icon(
            _speechToText.isNotListening ? Icons.mic : Icons.mic_off,
            color: _speechToText.isNotListening ? Colors.green : Colors.red,
          ),
          onPressed: _speechToText.isNotListening ? _startListening : _stopListening,
        ),
        Container(
          margin: EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () => setState(() {}),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: Text('Search', style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }

  // Show filter dialog
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Post Type Filter'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildFilterOption('All', null),
                _buildFilterOption('Blog', 'blog'),
                _buildFilterOption('Informative Article', 'informativeArticle'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _clearFilters();
                Navigator.pop(context);
              },
              child: Text('Clear Filters'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterOption(String title, String? value) {
    return ListTile(
      title: Text(title),
      leading: Radio<String?>(
        value: value,
        groupValue: _selectedPostType,
        onChanged: (value) {
          setState(() {
            _selectedPostType = value;
            Navigator.pop(context);
          });
        },
      ),
    );
  }

  // Show sort dialog
  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Sort By'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSortOption('Date', 'timestamp'),
              _buildSortOption('Alphabetic Order', 'title'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSortOption(String title, String value) {
    return ListTile(
      title: Text(title),
      leading: Radio<String>(
        value: value,
        groupValue: _sortField,
        onChanged: (value) {
          setState(() {
            _sortField = value!;
            Navigator.pop(context);
          });
        },
      ),
      trailing: IconButton(
        icon: Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward),
        onPressed: () {
          setState(() {
            _sortAscending = !_sortAscending;
            Navigator.pop(context);
          });
        },
      ),
    );
  }
}
