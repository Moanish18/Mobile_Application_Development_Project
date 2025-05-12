import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../firebase_service.dart';
import 'package:universal_html/html.dart' as html;

// NewPostScreen widget allows users to create a new post with a title, content, and image
class NewPostScreen extends StatefulWidget {
  final FirebaseService fbService = GetIt.instance<FirebaseService>();

  @override
  _NewPostScreenState createState() => _NewPostScreenState();
}

// Enum to define the type of post
enum PostType { informativeArticle, blog }

class _NewPostScreenState extends State<NewPostScreen> {
  final FirebaseService fbService = GetIt.instance<FirebaseService>(); // Firebase service instance
  final _formKey = GlobalKey<FormState>(); // Form key for validation
  final _contentController = TextEditingController(); // Controller for post content
  final _titleController = TextEditingController(); // Controller for post title
  PostType _postType = PostType.informativeArticle; // Default post type
  File? _image; // File for the selected image
  Uint8List? _imageBytes; // For web image handling

  // Function to pick an image from the gallery
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (kIsWeb) {
        // For web platform, read image as bytes
        final reader = html.FileReader();
        reader.readAsArrayBuffer(html.File([await pickedFile.readAsBytes()], pickedFile.name));
        reader.onLoadEnd.listen((event) {
          setState(() {
            _imageBytes = reader.result as Uint8List?;
          });
        });
      } else {
        // For mobile platforms, read image as file
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    }
  }

  // Function to take a photo using the camera
  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      if (kIsWeb) {
        // For web platform, read image as bytes
        final reader = html.FileReader();
        reader.readAsArrayBuffer(html.File([await pickedFile.readAsBytes()], pickedFile.name));
        reader.onLoadEnd.listen((event) {
          setState(() {
            _imageBytes = reader.result as Uint8List?;
          });
        });
      } else {
        // For mobile platforms, read image as file
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    }
  }

  // Function to upload the selected image to Firebase Storage
  Future<String?> _uploadImage() async {
    if (_image != null || _imageBytes != null) {
      String fileName = 'images/${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask;

      if (kIsWeb && _imageBytes != null) {
        // Upload image bytes for web
        uploadTask = storageRef.putData(_imageBytes!, SettableMetadata(contentType: 'image/jpeg'));
      } else if (_image != null) {
        // Upload image file for mobile
        uploadTask = storageRef.putFile(_image!, SettableMetadata(contentType: 'image/jpeg'));
      } else {
        return null; // No image to upload
      }

      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL(); // Return the image URL after upload
    }
    return null;
  }

  // Function to add a new post to Firebase Firestore
  void _addPost() async {
    if (_formKey.currentState!.validate()) {
      String? imageUrl = await _uploadImage();

      fbService.addPost(
        _titleController.text,
        _contentController.text,
        _postType.toString().split('.').last,
        imageUrl,
      ).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Post added successfully!')));
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error adding post: $error')));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait; // Check if the device is in portrait mode

    return Scaffold(
      appBar: AppBar(
        title: Text('New Post'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: isPortrait ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _buildFormContent(context),
          ) : Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Center(
                      child: Image.asset(
                        'images/greenhub_logo.png',
                        height: 50,
                      ),
                    ),
                    SizedBox(height: 20.0),
                    ..._buildFormContent(context).sublist(0, 3), // Up to the image buttons
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: _buildFormContent(context).sublist(3), // From the image preview onwards
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to build the form content
  List<Widget> _buildFormContent(BuildContext context) {
    return [
      SizedBox(height: 20.0),
      Text(
        'Title of Post',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      SizedBox(height: 8.0),
      TextFormField(
        controller: _titleController,
        decoration: InputDecoration(
          hintText: 'Enter title...',
          border: OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a title';
          }
          return null;
        },
        keyboardType: TextInputType.text,
      ),
      SizedBox(height: 16.0),
      Text(
        'Post Content',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      SizedBox(height: 8.0),
      TextFormField(
        controller: _contentController,
        maxLines: 5,
        decoration: InputDecoration(
          hintText: 'Write something...',
          border: OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter some content';
          }
          return null;
        },
        keyboardType: TextInputType.multiline,
      ),
      SizedBox(height: 16.0),
      Text(
        'Select Image',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      SizedBox(height: 8.0),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: _pickImage,
            icon: Icon(Icons.image),
            label: Text('Pick Image'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white, backgroundColor: Colors.blue,
            ),
          ),
          SizedBox(width: 16.0),
          ElevatedButton.icon(
            onPressed: _takePhoto,
            icon: Icon(Icons.camera_alt),
            label: Text('Take Photo'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white, backgroundColor: Colors.orange,
            ),
          ),
        ],
      ),
      SizedBox(height: 16.0),
      if (_image != null && !kIsWeb)
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.file(
            _image!,
            height: 150,
          ),
        ),
      if (_imageBytes != null && kIsWeb)
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.memory(
            _imageBytes!,
            height: 150,
          ),
        ),
      SizedBox(height: 16.0),
      Text(
        'Select Post Type',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      SizedBox(height: 8.0),
      Column(
        children: [
          ListTile(
            title: Text('Informative Article'),
            leading: Radio<PostType>(
              value: PostType.informativeArticle,
              groupValue: _postType,
              onChanged: (PostType? value) {
                setState(() {
                  _postType = value!;
                });
              },
            ),
          ),
          ListTile(
            title: Text('Blog'),
            leading: Radio<PostType>(
              value: PostType.blog,
              groupValue: _postType,
              onChanged: (PostType? value) {
                setState(() {
                  _postType = value!;
                });
              },
            ),
          ),
        ],
      ),
      SizedBox(height: 32.0),
      ElevatedButton(
        onPressed: _addPost,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          textStyle: TextStyle(fontSize: 16),
        ),
        child: Text('Post'),
      ),
    ];
  }
}
