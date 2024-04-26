import 'package:flutter/material.dart';
import 'dart:convert'; // For JSON processing
import 'package:http/http.dart' as http; // For making HTTP requests
import 'package:cached_network_image/cached_network_image.dart';
import 'news_article_detail_screen.dart';
import 'package:intl/intl.dart'; // Add this import for date formatting
import 'package:logger/logger.dart'; // Add this import for logging

var logger = Logger();

// Model class for a news article
class NewsArticle {
  final String title;
  final String description;
  final String url;
  final String author;
  final String publishedAt;
  final String? urlToImage; // Optional image URL

  NewsArticle({
    required this.title,
    this.description = '',
    required this.url,
    this.author = 'Unknown',
    required this.publishedAt,
    this.urlToImage,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? 'No Description',
      url: json['url'],
      author: json['author'] ?? 'Unknown',
      publishedAt: json['publishedAt'],
      urlToImage: json['urlToImage'],
    );
  }
}

// StatefulWidget for NewsScreen
class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  _NewsScreenState createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  List<NewsArticle> _newsArticles = [];

  @override
  void initState() {
    super.initState();
    _fetchNews();
  }

  Future<void> _fetchNews() async {
    const url = 'https://c8c4-178-62-65-5.ngrok-free.app/news';
    try {
      var response = await http.get(Uri.parse(url));
      var jsonData = jsonDecode(response.body);

      if (jsonData['status'] == 'ok') {
        setState(() {
          _newsArticles = List<NewsArticle>.from(jsonData['articles']
              .where((article) => article['urlToImage'] != null)
              .map((article) => NewsArticle.fromJson(article)));
        });
      } else {
        logger.i('Failed to load news: Status not OK');
      }
    } catch (e) {
      logger.i('Failed to load news: $e');
    }
  }

  String _displayDate(String publishedAt) {
    DateTime now = DateTime.now();
    DateTime publishedDate = DateTime.parse(publishedAt);
    Duration difference = now.difference(publishedDate);

    if (difference.inDays >= 7) {
      return DateFormat('yyyy-MM-dd').format(publishedDate);
    } else if (difference.inHours >= 24) {
      return '${difference.inDays} days ago';
    } else if (difference.inMinutes >= 60) {
      return '${difference.inHours} hours ago';
    } else if (difference.inSeconds >= 60) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('News'),
      ),
      body: ListView.builder(
        itemCount: _newsArticles.length,
        itemBuilder: (context, index) {
          final article = _newsArticles[index];
          String dateDisplay = _displayDate(article.publishedAt);
          return Card(
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: CachedNetworkImage(
                  imageUrl: article.urlToImage!,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
              title: Text(article.title),
              subtitle: Text('${article.author} - $dateDisplay'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      NewsArticleDetailScreen(url: article.url),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
