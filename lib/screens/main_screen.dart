import 'package:flutter/material.dart';
import 'add_post_screen.dart';
import 'search_screen.dart';
import 'user_posts_screen.dart';
import 'user_profile_screen.dart';

void main() {
  runApp(GreenHubApp());
}

class GreenHubApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GreenHub',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MainScreen(),
      routes: {
        '/': (context) => MainPostsPage(),
        '/new-post': (context) => NewPostScreen(),
        '/user-posts': (context) => UserPostsPage(),
        '/user-profile': (context) => UserProfilePage(),
        '/search': (context) => SearchPage(),
      },
    );
  }
}

// MainScreen widget that provides a bottom navigation bar to switch between different pages
class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0; // Current index of the selected bottom navigation item
  final PageController _pageController = PageController(); // PageController to manage page views

  final List<Widget> _pages = [
    MainPostsPage(),
    NewPostScreen(),
    UserPostsPage(),
    UserProfilePage(),
  ];

  // Method to handle tap events on the bottom navigation bar items
  void onTabTapped(int index) {
    if (index == 4) {
      Navigator.pushNamed(context, '/search');
    } else {
      setState(() {
        _currentIndex = index;
      });
      _pageController.jumpToPage(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: _pages,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: onTabTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'New Post',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_library),
            label: 'My Posts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
        ],
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}

// MainPostsPage widget that displays the main posts page
class MainPostsPage extends StatelessWidget {
  final List<Post> posts = [
    Post(
      user: 'Two Sisters Pantry',
      date: '18 March 2024',
      content: 'Happy Monday! Our Organic Spelt Milk would be a flavourful and nutritious addition to your coffee for a kickstart to your day and a step closer to a greener world! Get yours at Two Sister’s Pantry! 🌱🥛☕️',
      imageUrl: 'images/spelt_milk.jpg',
      profileImageUrl: 'images/profile_two_sisters_pantry.jpg',
      icon: Icons.share,
    ),
    Post(
      user: 'Paleska Reki Segoai',
      date: '29 April 2024',
      content: 'Building a home is expensive.  I want an eco-friendly home  plus it is affordable.',
      imageUrl: 'images/Eco-Friendly-House.jpg',
      profileImageUrl: 'images/profile_paleska.png',
      icon: Icons.share,
    ),
    Post(
      user: 'Live Green, Love Green',
      date: '9 April 2024',
      content: 'Who knew litter picking could be this enjoyable, eh? It’s definitely lots of fun when you do it with a group! 🤣💜🚯',
      imageUrl: 'images/litter-picker.jpeg',
      profileImageUrl: 'images/profile_live_green.jpg',
      icon: Icons.share,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'images/greenhub_logo.png',
          height: 40,
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'images/green_background.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Overlay with semi-transparent black color
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: posts.map((post) => PostCard(post: post)).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// PostCard widget that displays individual post details
class PostCard extends StatelessWidget {
  final Post post;

  PostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage(post.profileImageUrl),
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post.user, style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(post.date, style: TextStyle(color: Colors.grey)),
                  ],
                ),
                Spacer(),
              ],
            ),
            SizedBox(height: 10.0),
            Text(post.content),
            SizedBox(height: 10.0),
            Image.asset(post.imageUrl),
          ],
        ),
      ),
    );
  }
}

// Post class to hold post data
class Post {
  final String user;
  final String date;
  final String content;
  final String imageUrl;
  final String profileImageUrl;
  final IconData icon;

  Post({
    required this.user,
    required this.date,
    required this.content,
    required this.imageUrl,
    required this.profileImageUrl,
    required this.icon,
  });
}