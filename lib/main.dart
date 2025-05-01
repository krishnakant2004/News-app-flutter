import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:newsapp/widgets/swipe_detcted.dart';

void main() {
  runApp(const NewsApp());
}

class NewsApp extends StatelessWidget {
  const NewsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stacked News Viewer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      home: NewsFeed(),//NewsViewer(),
    );
  }
}

class NewsArticle {
  final String title;
  final String description;
  final String imageUrl;
  final String source;
  final String publishedAt;
  final String url;

  NewsArticle({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.source,
    required this.publishedAt,
    required this.url,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'] ?? 'No title available',
      description: json['description'] ?? 'No description available',
      imageUrl: json['urlToImage'] ?? 'https://picsum.photos/800/1200',
      source: json['source']['name'] ?? 'Unknown source',
      publishedAt: json['publishedAt'] ?? '',
      url: json['url'] ?? '',
    );
  }
}

class NewsViewer extends StatefulWidget {
  const NewsViewer({super.key});

  @override
  State<NewsViewer> createState() => _NewsViewerState();
}

class _NewsViewerState extends State<NewsViewer> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  List<NewsArticle> _articles = [];
  final List<String> _countryList = [
    'India',
    'united Kingdom',
    'United State',
    'Russia'
  ];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchNews();
  }

  Future<void> _fetchNews() async {
    const apiKey =
        '512eef2a14b7486194e31e2ebfdf227c'; // Replace with your NewsAPI key
    const url =
        'https://newsapi.org/v2/top-headlines?country=us&apiKey=$apiKey';

    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final articles = (data['articles'] as List)
            .map((article) => NewsArticle.fromJson(article))
            .where((article) =>
                article.imageUrl.isNotEmpty &&
                article.description.isNotEmpty &&
                !article.imageUrl.contains('placeholder'))
            .toList();

        setState(() {
          _articles = articles;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load news');
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to fetch news: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "News App",
            style: TextStyle(color: Colors.blue),
          ),
          backgroundColor: Colors.black38,
          shape: const Border(bottom: BorderSide(color: Colors.black38, width: 1)),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(40), // Fixed height
            child: SizedBox(
              height: 40, // Constrain ListView's height
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                itemCount: _countryList.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8), // Add spacing
                  child: Text(
                    _countryList[index],
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _fetchNews,
              color: Colors.blue,
            ),
          ],
        ),

        body: Stack(
        children: [
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            )
          else if (_error != null)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchNews,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          else if (_articles.isEmpty)
            const Center(
              child: Text('No news articles available'),
            )
          else
            Stack(
              children: [
                // Stacked Cards
                PageView.builder(
                  controller: _pageController,
                  scrollDirection: Axis.vertical,
                  itemCount: _articles.length,
                  onPageChanged: (int page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  itemBuilder: (context, index) {
                    return NewsCard(
                      article: _articles[index],
                      isActive: index == _currentPage,
                    );
                  },
                ),

                // Progress Indicator
                Positioned(
                  right: 20,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Container(
                      width: 4,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return Column(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                height: constraints.maxHeight *
                                    (_currentPage + 1) /
                                    _articles.length,
                                width: 4,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class NewsCard extends StatelessWidget {
  final NewsArticle article;
  final bool isActive;

  const NewsCard({
    super.key,
    required this.article,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: article.url,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        transform: Matrix4.identity()
          ..translate(
            0.0,
            isActive ? 0.0 : 20.0,
            0.0,
          ),
        child: Card(
          margin: const EdgeInsets.all(0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image
              Image.network(
                article.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[900],
                    child: const Center(
                      child: Icon(
                        Icons.error_outline,
                        color: Colors.white54,
                        size: 48,
                      ),
                    ),
                  );
                },
              ),

              // Gradient Overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.8),
                    ],
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.source,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white.withOpacity(0.8),
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      article.title,
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      article.description,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withOpacity(0.8),
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatDate(article.publishedAt),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.6),
                          ),
                    ),
                  ],
                ),
              ),

              // Clickable Area
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    // Launch URL
                    // You'll need to add url_launcher package and implement URL launching
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}
