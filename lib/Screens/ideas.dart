import 'package:flutter/material.dart';
import 'package:meal/Screens/add_recipe.dart';

class IdeasTab extends StatefulWidget {
  const IdeasTab({super.key});

  @override
  State<IdeasTab> createState() => Ideas();
}

class Ideas extends State<IdeasTab> {
  static const Color accentColor = Color(0xDBF32607); // International Orange


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
            sectionTitle("Community favorites"),
            CommunitySection(),
            sectionTitle("Explore More"),
            ExploreMoreSection(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: (){
          Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => AddRecipeScreen()));
      },
        label: Container(
          width: 120,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Icon(Icons.add, color: Colors.white),
              ),
              Text('Share recipe', style: TextStyle(
                  color: Colors.white
              ),)
            ],
          ),
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