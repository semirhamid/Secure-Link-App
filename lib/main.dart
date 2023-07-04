import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Malicious Detect App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MaliciousDetectPage(),
    );
  }
}

class MaliciousDetectPage extends StatefulWidget {
  @override
  _MaliciousDetectPageState createState() => _MaliciousDetectPageState();
}

class _MaliciousDetectPageState extends State<MaliciousDetectPage> {
  List<Map<String, dynamic>> _urlResults = [];
  TextEditingController _urlController = TextEditingController();

  var green = [Color(0xFF8FD9A8), Color(0xFF70BF85)];
  var red = [Color(0xFFE57373), Color(0xFFEF5350)];

  @override
  void initState() {
    super.initState();
  }

  Future<void> _analyzeUrl(String url) async {
    String apiKey =
        '2c6f650d69eb9a94b5147bd200d174ab59091b3b1f287b3094d9aadebb544b91';
    String apiUrl =
        'https://www.virustotal.com/vtapi/v2/url/report?apikey=$apiKey&resource=$url';

    Map<String, String> headers = {
      'accept': 'application/json',
    };

    try {
      final response = await http.get(Uri.parse(apiUrl), headers: headers);

      if (response.statusCode == 200) {
        Map<String, dynamic> result = jsonDecode(response.body);
        if (result.containsKey('scans')) {
          Map<String, dynamic> scans = result['scans'];
          List<Map<String, dynamic>> urlResults = [];

          scans.forEach((key, value) {
            String scanner = key;
            bool detected = value['detected'];
            String scanResult = value['result'];
            var resultColor = detected;

            urlResults.add({
              'scanner': scanner,
              'result': scanResult,
              'resultColor': resultColor,
            });
          });

          setState(() {
            _urlResults = urlResults;
          });
        }
      } else {
        throw Exception('Failed to fetch URL analysis');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Malicious Detect App'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _urlResults.length,
              itemBuilder: (context, index) {
                String scanner = _urlResults[index]['scanner'];
                String result = _urlResults[index]['result'];
                bool resultColor = _urlResults[index]['resultColor'];

                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    gradient: LinearGradient(
                      colors: resultColor
                          ? const [Color(0xFFE57373), Color(0xFFEF5350)]
                          : const [Color(0xFF8FD9A8), Color(0xFF70BF85)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Card(
                    elevation: 0.0,
                    color: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: ListTile(
                      title: Text(
                        'Scanner: $scanner',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        'Result: $result',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: TextField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: 'Enter URL',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              String url = _urlController.text;
              if (url.isNotEmpty) {
                _analyzeUrl(url);
              }
            },
            child: Text('Analyze URL'),
          ),
        ],
      ),
    );
  }
}
