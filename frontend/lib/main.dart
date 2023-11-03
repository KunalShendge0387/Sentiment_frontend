import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SentimentAnalysisScreen(),
    );
  }
}

class SentimentAnalysisScreen extends StatefulWidget {
  @override
  _SentimentAnalysisScreenState createState() =>
      _SentimentAnalysisScreenState();
}

class _SentimentAnalysisScreenState extends State<SentimentAnalysisScreen> {
  final TextEditingController twitterHandleController = TextEditingController();
  final TextEditingController tweetsDesiredController = TextEditingController();
  String sentimentResults = "";
  List<String> sentimentScores = [];
  String handle = "";
  String number = "";
  bool isLoading = false; // Add loading indicator state

  Future<void> fetchSentimentAnalysis() async {
    setState(() {
      isLoading = true; // Show loading indicator
    });

    final String url =
        "http://127.0.0.1:5000/senti"; // Replace with your server URL

    final Map<String, dynamic> requestBody = {
      'handle': handle,
      'tweetsDesired': int.tryParse(number) ?? 10,
    };

    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final results = data['results'];

      setState(() {
        sentimentResults = ""; // Clear the previous results
        sentimentScores.clear();

        for (var result in results) {
          final tweetNumber = result['Tweet Number'];
          final tweetText = result['Tweet Text'];
          final sentiment = result['Sentiment Analysis'];
          final scores = result['Sentiment Scores'];

          sentimentScores.add("Tweet $tweetNumber:");
          sentimentScores.add("Text: $tweetText");
          sentimentScores.add("Sentiment: $sentiment");

          // Iterate through the scores dictionary and add each key-value pair separately
          for (var key in scores.keys) {
            final value = scores[key];
            sentimentScores.add("$key: $value");
          }

          sentimentScores.add(""); // Add a separator between tweets
        }

        isLoading = false; // Hide loading indicator
      });
    } else {
      setState(() {
        sentimentResults = "Error: Unable to fetch sentiment analysis results.";
        sentimentScores.clear();
        isLoading = false; // Hide loading indicator
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sentiment Analysis App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              onChanged: (value) {
                handle = value;
              },
              controller: twitterHandleController,
              decoration: InputDecoration(labelText: 'Twitter Handle'),
            ),
            TextField(
              controller: tweetsDesiredController,
              onChanged: (value) {
                number = value;
              },
              decoration:
                  InputDecoration(labelText: 'Number of Tweets (default: 10)'),
            ),
            ElevatedButton(
              onPressed: fetchSentimentAnalysis,
              child: Text('Fetch Sentiment Analysis'),
            ),
            SizedBox(height: 20),
            if (isLoading)
              CircularProgressIndicator() // Show loading indicator while fetching data
            else
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: sentimentScores
                        .map((text) => Text(
                              text,
                              style: TextStyle(fontSize: 16),
                            ))
                        .toList(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
