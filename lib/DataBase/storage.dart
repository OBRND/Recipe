import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:meal/DataBase/fetch_db.dart';
import 'dart:io';
import '../Keys.dart';

Future<String?> uploadImage(File imageFile, String id) async {
  const int sizeLimitInBytes = 5 * 1024 * 1024; // 5 MB
  final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/upload');

  try {
    // Read the image file into a Uint8List
    Uint8List imageBytes = await imageFile.readAsBytes();

    // Check if the image is already below the size limit
    if (imageBytes.length <= sizeLimitInBytes) {
      print('Image is already below the size limit. Uploading as is...');
    } else {
      print('Image exceeds the size limit. Compressing...');
      // Compress the image to meet the size limit
      imageBytes = await compressImageToSize(imageBytes, sizeLimitInBytes) ?? imageBytes;
    }

    // Create the multipart request
    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = 'preset_1'
      ..files.add(http.MultipartFile.fromBytes(
        'file',
        imageBytes,
        filename: '$id.webp', // Use WebP for better compression
      ));

    // Send the request
    final response = await request.send();
    print('Upload status code: ${response.statusCode}');

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

Future<Uint8List?> compressImageToSize(Uint8List imageBytes, int sizeLimitInBytes) async {
  int quality = 100; // Start with maximum quality
  Uint8List? compressedImage = imageBytes;

  while (compressedImage!.length > sizeLimitInBytes && quality > 0) {
    quality -= 5; // Reduce quality by 5% in each iteration
    compressedImage = await FlutterImageCompress.compressWithList(
      compressedImage,
      quality: quality,
      format: CompressFormat.webp, // Use WebP for better compression
    );

    if (compressedImage == null) {
      break; // Stop if compression fails
    }
  }

  return compressedImage;
}

Future<Uint8List?> fetchImage(String recipeId, String imageUrl) async {
  final imageBox = Hive.box('images');

  // Check if the image is in the local database
  if (imageBox.containsKey(recipeId)) {
    return imageBox.get(recipeId);
  }

  // If not found and the app is online, fetch the image
  try {
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      final imageBytes = await convertToWebP(response.bodyBytes);

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

Future<void> fetchAndStoreRecipes(String uid) async {
  final recipesBox = Hive.box('recipes');

  try {
    // Fetch recipes from Firebase
    List<Map<String, dynamic>> recipes = await Fetch(uid: uid).getAllRecipes();

    for (var recipe in recipes) {
      // Skip the Community document
      if (recipe['id'] == 'community') continue;

      // Convert Timestamp fields to DateTime strings
      recipe.forEach((key, value) {
        if (value is Timestamp) {
          recipe[key] = value.toDate().toIso8601String();
        }
      });

      // Save the cleaned recipe to Hive
      String recipeId = recipe['id'];
      recipesBox.put(recipeId, recipe);
    }

    print('Recipes successfully stored in Hive.');
  } catch (e) {
    print('Error fetching or storing recipes: $e');
  }
}


Future<List<Map<String, dynamic>>> getSavedRecipesFromHive(recipeIds, uid) async {
  final recipesBox = Hive.box('recipes');
  List<Map<String, dynamic>> recipes = [];

  // Check if there are any recipe IDs to process
  if (recipeIds.isEmpty) {
    print("No data");
    return [];
  }

  // Retrieve recipe details from Hive
  for (String id in recipeIds) {
    var recipeDetails = recipesBox.get(id); // Fetch recipe by ID from Hive

    if (recipeDetails == null) {
      // Fetch from Firebase if not found in Hive
      var recipe = await Fetch(uid: uid).getSingleRecipe(id);

      if (recipe['timestamp'] is Timestamp) {
        recipe['timestamp'] = recipe['timestamp'].toDate().toIso8601String();
      }

      await recipesBox.put(id, recipe); // Save to Hive
      recipeDetails = recipe; // Update variable with newly stored data
    }

    // Now recipeDetails is always valid, add to the list
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

  return recipes;
}

Future<Uint8List> convertToWebP(Uint8List imageBytes) async {

  final result = await FlutterImageCompress.compressWithList(
    imageBytes,
    format: CompressFormat.webp, // Specify WebP format
    quality: 75, // Set the desired quality (0-100)
  );

  return result;
}




