import 'package:flutter/material.dart';

void main() {
  runApp(const HalalFinderApp());
}

class HalalFinderApp extends StatelessWidget {
  const HalalFinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Halal Finder',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const ContentView(),
    );
  }
}

class ContentView extends StatefulWidget {
  const ContentView({super.key});

  @override
  _ContentViewState createState() => _ContentViewState();
}

class _ContentViewState extends State<ContentView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Halal Finder'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to Halal Finder!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement restaurant search functionality
              },
              child: const Text('Find Halal Restaurants'),
            ),
          ],
        ),
      ),
    );
  }
}