import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;

Future<Map<String, List<String>>> loadAdjectiveMap() async {
  final String jsonString =
  await rootBundle.loadString('assets/positive_words_by_letter.json');
  final Map<String, dynamic> jsonMap = json.decode(jsonString);
  return jsonMap.map(
    ((key, value) => MapEntry(key.toUpperCase(), List<String>.from(value as List))),
  );
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Acrostic Virtue',
      theme: ThemeData.dark(useMaterial3: true),
      debugShowCheckedModeBanner: false,
      home: const SearchScreen(title: 'Acrostic Virtue'),
    );
  }
}

class SearchScreen extends StatefulWidget {
  final String title;

  const SearchScreen({super.key, required this.title});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  Map<String, List<String>> adjectiveMap = {};
  List<String> results = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    loadAdjectiveMap().then((map) {
      setState(() {
        adjectiveMap = map;
      });
    });
  }

  void _generateAdjective(String name) {
    List<String> output = [];

    for (int i = 0; i < name.length; i++) {
      String letter = name[i].toUpperCase();

      if (adjectiveMap.containsKey(letter)) {
        List<String> adjectives = adjectiveMap[letter]!;
        String adjective = adjectives[_random.nextInt(adjectives.length)];
        output.add("$letter is for $adjective");
      } else {
        output.add('$letter is for [no word found]');
      }
    }

    setState(() {
      results = output;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title,
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: results.length,
                itemBuilder: (context, index) {
                  return Text(results[index],
                      style: const TextStyle(fontSize: 15));
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar:
      Padding(
        padding: MediaQuery.of(context).viewInsets + const EdgeInsets.all(10.0),
        child: TextField(
          controller: _controller,
          decoration: InputDecoration(
            labelText: 'Enter a name',
            border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onSubmitted: _generateAdjective,
        ),
      ),
    );
  }
}
