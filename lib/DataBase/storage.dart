import 'dart:convert';
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


