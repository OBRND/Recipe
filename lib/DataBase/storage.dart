import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import '../Keys.dart';

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

Future<void> saveImageLocally(String recipeId, String imageUrl) async {
  final box = Hive.box('images');
  final appDir = Directory.systemTemp.path;

  // Define image path
  final imagePath = '$appDir/$recipeId.png';

  if (!File(imagePath).existsSync()) {
    // Download and save the image
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      final file = File(imagePath);
      await file.writeAsBytes(response.bodyBytes);
      box.put(recipeId, imagePath); // Save path in Hive
    }
  }
}

Future<String?> getImagePath(String recipeId) async {
  final box = Hive.box('images');
  return box.get(recipeId) as String?;
}


