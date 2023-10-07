import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'RandomImage.dart';

class ImageScreen extends StatefulWidget {
  @override
  _ImageScreenState createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {
  List<String> imageUrls = [];
  bool isLoading = false;
  TextEditingController searchController = TextEditingController();
  int _currentIndex = 0;
  String searchMessage = '';

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> fetchWikipediaImages(String animalName) async {
    setState(() {
      isLoading = true;
    });

    final response = await http.get(
      Uri.parse(
          'https://en.wikipedia.org/w/api.php?action=query&format=json&prop=images&titles=$animalName'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final pages = data['query']['pages'];
      if (pages != null) {
        final firstPage = pages.entries.first.value;
        final images = firstPage['images'];
        if (images != null) {
          for (var image in images) {
            final title = image['title'];
            final imageUrl = 'https://en.wikipedia.org/wiki/Special:FilePath/' +
                Uri.encodeFull(title) +
                '?width=300'; // You can adjust the width as needed
            imageUrls.add(imageUrl);
          }
        }
      }
      setState(() {
        isLoading = false;
      });

      // Check if no results were found
      if (imageUrls.isEmpty) {
        setState(() {
          searchMessage = 'No results found for "$animalName".';
        });
      } else {
        setState(() {
          searchMessage = '';
        });
      }
    } else {
      throw Exception('Failed to load');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Viewer'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.black,
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Enter animal name',
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: BorderSide(
                      color: Colors.white,
                      width: 0.0,
                    ),
                  ),
                ),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final animalName = searchController.text;
              if (animalName.isNotEmpty) {
                imageUrls.clear(); // Clear previous search results
                fetchWikipediaImages(animalName);
              }
            },
            child: Text('Search'),
          ),
          Expanded(
            child: isLoading
                ? Center(
              child: CircularProgressIndicator(),
            )
                : imageUrls.isEmpty
                ? Center(
              child: Text(
                searchMessage,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
                : ListView.builder(
              itemCount: imageUrls.length,
              itemBuilder: (context, index) {
                final imageUrl = imageUrls[index];
                return ListTile(
                  title: Image.network(imageUrl),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: onTabTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: InkWell(
              onTap: (){
                Navigator.of(context).pushReplacement(_fadeInPageRoute());
              },
                child: Icon(Icons.search)),
            label: ' Random Search',

          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
PageRouteBuilder _fadeInPageRoute() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) =>RandomImageScreen(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = 0.0;
      const end = 1.0;
      var tween = Tween(begin: begin, end: end);
      var opacityAnimation = animation.drive(tween);

      return FadeTransition(
        opacity: opacityAnimation,
        child: child,
      );
    },
  );
}
