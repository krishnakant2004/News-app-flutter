import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
class NewsFeed extends StatefulWidget {
  const NewsFeed({super.key});

  @override
  _NewsFeedState createState() => _NewsFeedState();
}

class _NewsFeedState extends State<NewsFeed> with SingleTickerProviderStateMixin {
  List<dynamic> articles = [];
  int currentIndex = 0;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fetchNews();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  Future<void> _fetchNews() async {

    const apiKey =
        '512eef2a14b7486194e31e2ebfdf227c'; // Replace with your NewsAPI key
    const url =
        'https://newsapi.org/v2/top-headlines?country=us&apiKey=$apiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print("Response: $data"); // Debugging

      if (data['articles'] != null && data['articles'].isNotEmpty) {
        setState(() {
          articles = data['articles'];
        });
      } else {
        print("No articles found");
      }
    } else {
      print("Failed to fetch news: ${response.statusCode}");
    }
  }

  void _swipeUp() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
      });
      _animationController.reset();
      _animationController.forward();
    }
  }

  void _swipeDown() {
    if (currentIndex < articles.length - 1) {
      setState(() {
        currentIndex++;
      });
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DevBytes News'),
      ),
      body: articles.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : GestureDetector(
        onVerticalDragUpdate: (details) {
          if (details.primaryDelta! < -10) {
            _swipeDown();
          } else if (details.primaryDelta! > 10) {
            _swipeUp();
          }
        },
        child: SlideTransition(
          position: _slideAnimation,
          child: NewsWidget(
            article: articles[currentIndex],
          ),
        ),
      ),
    );
  }
}

class NewsWidget extends StatelessWidget {
  final dynamic article;

  NewsWidget({required this.article});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article['urlToImage'] != null)
              Image.network(
                article['urlToImage'],
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey,
                    child: const Center(child: Text('Image not available')),
                  );
                },
              ),
            const SizedBox(height: 16),
            Text(
              article['title'] ?? 'No title',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              article['description'] ?? 'No description',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Source: ${article['source']?['name'] ?? 'Unknown'}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
