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

Future<UserDataModel?> getUserDataFromHive() async {
  final userBox = Hive.box('userData');
  final cachedData = userBox.get('userInfo');

  if (cachedData != null) {
    return UserDataModel.fromMap(Map<String, dynamic>.from(cachedData));
  }
  return null; // No data found in Hive
}

Future<UserDataModel?> fetchUserData(String userId) async {
  final userBox = Hive.box('userData');

  try {
    // Try to fetch from Hive first
    final offlineData = await getUserDataFromHive();
    if (offlineData != null) {
      return offlineData;
    }

    // If no data in Hive, fetch from Firestore
    final snapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .get();

    if (snapshot.exists) {
      final userData = UserDataModel.fromMap(snapshot.data()!);

      // Save fetched data to Hive
      userBox.put('userInfo', userData.toMap());

      return userData;
    }
  } catch (e) {
    print('Error fetching user data: $e');
  }

  return null;
}




