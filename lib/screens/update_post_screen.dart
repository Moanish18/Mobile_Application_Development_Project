import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../firebase_service.dart';

class UpdatePostPage extends StatefulWidget {
  final String postId;

  UpdatePostPage({required this.postId});

  @override
  _UpdatePostPageState createState() => _UpdatePostPageState();
}

class _UpdatePostPageState extends State<UpdatePostPage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isLoading = true;
  String? _imageUrl;
  String? _postType;

  @override
  void initState() {
    super.initState();
    _fetchPostDetails();
  }

  void _fetchPostDetails() async {
    var postDoc = await FirebaseFirestore.instance.collection('posts').doc(widget.postId).get();
    if (postDoc.exists) {
      var postData = postDoc.data();
      setState(() {
        _titleController.text = postData?['title'] ?? '';
        _contentController.text = postData?['content'] ?? '';
        _imageUrl = postData?['imageUrl'];
        _postType = postData?['postType'];
        _isLoading = false;
      });
    }
  }

  void _updatePost() {
    if (_validateInputs()) {
      FirebaseService()
          .updatePost(
            widget.postId,
            _titleController.text,
            _contentController.text,
            _postType!,
            _imageUrl,
          )
          .then((_) {
        _showUpdateDialog(context);
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $error')));
      });
    }
  }

  bool _validateInputs() {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter a title')));
      return false;
    }
    if (_contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter some content')));
      return false;
    }
    return true;
  }

  void _deletePost() async {
    try {
      // Delete the post document from Firestore
      await FirebaseFirestore.instance.collection('posts').doc(widget.postId).delete();

      // Delete the image from Firebase Storage if it exists
      if (_imageUrl != null && _imageUrl!.isNotEmpty) {
        await FirebaseStorage.instance.refFromURL(_imageUrl!).delete();
      }

      _showDeleteDialog(context);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $error')));
    }
  }

  void _showFullSizeImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      appBar: AppBar(
        title: Text('Update/Delete Post'),
        backgroundColor: Colors.green,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: isPortrait ? _buildPortraitLayout(context) : _buildLandscapeLayout(context),
            ),
    );
  }

  Widget _buildPortraitLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _buildFormContent(context),
    );
  }

  Widget _buildLandscapeLayout(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _buildFormContent(context).sublist(0, 2), // Image and title
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _buildFormContent(context).sublist(2), // Content and buttons
          ),
        ),
      ],
    );
  }

  List<Widget> _buildFormContent(BuildContext context) {
    return [
      _imageUrl != null && _imageUrl!.isNotEmpty
          ? GestureDetector(
              onTap: () => _showFullSizeImage(context, _imageUrl!),
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.network(
                    _imageUrl!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
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
                      return Text('Error loading image');
                    },
                  ),
                ),
              ),
            )
          : Container(),
      SizedBox(height: 20),
      TextFormField(
        controller: _titleController,
        decoration: InputDecoration(
          labelText: 'Title',
          labelStyle: TextStyle(color: Colors.green),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.green),
          ),
          filled: true,
          fillColor: Colors.grey[200],
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a title';
          }
          return null;
        },
        keyboardType: TextInputType.text,
      ),
      SizedBox(height: 20),
      TextFormField(
        controller: _contentController,
        decoration: InputDecoration(
          labelText: 'Content',
          labelStyle: TextStyle(color: Colors.green),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.green),
          ),
          filled: true,
          fillColor: Colors.grey[200],
        ),
        maxLines: 5,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter some content';
          }
          return null;
        },
        keyboardType: TextInputType.multiline,
      ),
      SizedBox(height: 20),
      Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: _updatePost,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: Text(
                'Update',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _showConfirmDeleteDialog(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: Text(
                'Delete',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  void _showUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Post'),
          content: Text('This post has been updated successfully!'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showConfirmDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete', style: TextStyle(color: Colors.red)),
          content: Text('Are you sure you want to delete this post?', style: TextStyle(color: Colors.red)),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            // Commenting out the Delete button
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deletePost();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Post'),
          content: Text('This post has been deleted successfully!'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
