import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import '../Keys.dart';
import '../Models/user_data.dart';

Future<String?> uploadImage(File imageFile) async {
  // Replace with your Cloudinary cloud name

  final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/upload');

  try {
    final request = http.MultipartRequest('POST', url);
    request.fields['upload_preset'] = 'preset_1';
    request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    // Send the request
    final response = await request.send();
    print(response.statusCode);

    if (response.statusCode == 200) {
      final responseData = await http.Response.fromStream(response);
      final jsonResponse = jsonDecode(responseData.body);
      return jsonResponse['secure_url']; // URL of the uploaded image
    } else {
      print('Failed to upload image: ${response.reasonPhrase}');
      return null;
    }
  } catch (e) {
    print('Error uploading image: $e');
    return null; // Return null if upload fails
  }
}

Future<Uint8List?> fetchImage(String recipeId, String imageUrl) async {
  final imageBox = Hive.box('images');

  // Check if the image is in the local database
  if (imageBox.containsKey(recipeId)) {
    print('Image found in local database for recipe ID: $recipeId');
    return imageBox.get(recipeId);
  }

  // If not found and the app is online, fetch the image
  try {
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      final imageBytes = response.bodyBytes;

      // Save the image in the Hive database
      imageBox.put(recipeId, imageBytes);
      print('Image saved to local database for recipe ID: $recipeId');
      return imageBytes;
    } else {
      print('Failed to fetch image for recipe ID: $recipeId');
    }
  } catch (e) {
    print('Error fetching image for recipe ID: $recipeId - $e');
  }

  return null;
}

Future<List<Map<String, dynamic>>> getSavedRecipesFromHive(List<String> recipeIds) async {
  final recipesBox = Hive.box('recipes');
  List<Map<String, dynamic>> recipes = [];

  // Check if there are any recipe IDs to process
  if (recipeIds.isEmpty) {
    print("No data");
    return [];
  }

  // Retrieve recipe details from Hive
  for (String id in recipeIds) {
    final recipeDetails = recipesBox.get(id); // Fetch recipe by ID from Hive
    if (recipeDetails != null) {
      recipes.add({
        'id': id,
        'name': recipeDetails['name'],
        'cal': recipeDetails['cal'],
        'ingredients': recipeDetails['ingredients'],
        'cookingTime': recipeDetails['cookingTime'],
        'imageUrl': recipeDetails['imageUrl'],
        'favoritesCount': recipeDetails['favoritesCount'],
      });
    }
  }

  return recipes;
}





