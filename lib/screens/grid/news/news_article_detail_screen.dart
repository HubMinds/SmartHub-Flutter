import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:logger/logger.dart';

var logger = Logger();

class NewsArticleDetailScreen extends StatefulWidget {
  final String url;

  const NewsArticleDetailScreen({required this.url, Key? key})
      : super(key: key);

  @override
  _NewsArticleDetailScreenState createState() =>
      _NewsArticleDetailScreenState();
}

class _NewsArticleDetailScreenState extends State<NewsArticleDetailScreen> {
  late WebViewController controller;
  double progress = 0.0; // Initial progress indicator value

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progressValue) {
            setState(() {
              progress =
                  progressValue / 100; // Update progress based on loading
            });
            logger.i("Loading progress: $progressValue%");
          },
          onPageStarted: (String url) {
            logger.i("Page started loading: $url");
          },
          onPageFinished: (String url) {
            setState(() {
              progress = 0.0; // Reset progress when page finishes loading
            });
            logger.i("Page finished loading: $url");
          },
          onWebResourceError: (WebResourceError error) {
            logger.i("Web resource error: ${error.description}");
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('News Article Detail'),
        // Display the progress bar in the AppBar
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3.0),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        ),
      ),
      body: WebViewWidget(controller: controller),
    );
  }
}
