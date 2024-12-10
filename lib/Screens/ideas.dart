import 'package:flutter/material.dart';

class IdeasTab extends StatefulWidget {
  const IdeasTab({super.key});

  @override
  State<IdeasTab> createState() => Ideas();
}

class Ideas extends State<IdeasTab> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Community Ideas'),),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            sectionTitle("Recommended for You"),
            RecommendedSection(),
            sectionTitle("Community Picks"),
            CommunitySection(),
            sectionTitle("Explore More"),
            ExploreMoreSection(),
          ],
        ),
      ),
    );
  }

  Widget sectionTitle(title) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class RecommendedSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Replace this placeholder with the logic to display recommended recipes.
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5, // Example count
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.all(8),
            child: Container(width: 150, color: Colors.grey[300]),
          );
        },
      ),
    );
  }
}

class CommunitySection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Replace this placeholder with the logic to display trending recipes.
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5, // Example count
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.all(8),
            child: Container(width: 150, color: Colors.grey[300]),
          );
        },
      ),
    );
  }
}

class ExploreMoreSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Replace this placeholder with the logic to display additional content.
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text("Explore more content coming soon..."),
    );
  }
}