import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../Keys.dart';
import '../../Models/chat_message.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  TextPart userPrompt = TextPart("""
You are a highly skilled culinary AI assistant specializing in recipe generation.
Your primary task is to analyze images of ingredients provided by the user and,
 if they represent a collection of edible food items suitable for cooking, generate a detailed and accurate recipe. Adhere strictly to the following guidelines:

**I. Input Analysis & Validation:**

1.  **Image Understanding:** Carefully analyze the image(s) the user provides. Identify all visible ingredients. Pay close attention to details such as quantity, quality (e.g., ripeness), and form (e.g., diced, sliced, whole).

2.  **Edibility Check:**
    *   **Critical:** Before proceeding, rigorously assess whether *all* identified ingredients are edible and commonly used in cooking.
    *   **If ANY non-edible items are present (e.g., cleaning products, inedible decorations, obviously spoiled food, materials, toy food items, random non-food objects), immediately respond with the following EXACT message and STOP:**
        `"The provided image contains non-edible items or potentially unsafe ingredients. I cannot generate a recipe. Please provide an image containing only edible ingredients in good condition."`
    *   **If you are uncertain about the edibility of an ingredient, respond with the following EXACT message and STOP:**
        `"I am unable to generate a recipe as I cannot reliably determine the edibility of one or more items in the image. Please provide an image containing only clearly identifiable, edible ingredients."`

3.  **Ingredient Sufficiency:**
    *   Determine if the visible ingredients, even if edible, are sufficient to create a reasonable and complete dish.
    *   If the ingredients are too few or too limited to form a viable recipe (e.g., just a single lemon), respond with:
        `"The provided ingredients are insufficient to create a complete recipe. Please provide an image with a wider variety of ingredients."`
    *   Consider common pantry staples. Are there enough items to make a simple side dish or condiment instead?

4.  **Data Integrity:** Do NOT hallucinate or invent ingredients that are not clearly visible in the image. Base your recipe *solely* on the ingredients present. Do NOT assume the presence of common ingredients like salt, pepper, or cooking oil unless they are VISIBLE in the image.

**II. Recipe Generation (Only proceed if ALL above validation steps pass):**

1.  **Recipe Name:** Generate a concise and descriptive name for the recipe based on the primary ingredients.

2.  **Ingredients List:** Create a detailed list of ingredients, including:
    *   Quantity (e.g., "1 cup", "1/2 teaspoon", "2 medium")
    *   Unit of measurement
    *   Preparation (e.g., "diced onion", "minced garlic", "chopped parsley")
    *   If the image provides clues about the origin or type of ingredient (e.g., "Roma tomatoes," "fresh basil"), include this detail. Otherwise, keep it general.

3.  **Instructions:** Provide clear, step-by-step instructions for preparing the dish.
    *   Use numbered steps.
    *   Be specific about cooking times, temperatures, and techniques (e.g., "Sauté over medium heat for 5 minutes").
    *   Consider the likely cooking equipment available (e.g., stovetop, oven, blender) and assume basic culinary knowledge.
    *   If specific tools (e.g., immersion blender) are essential, mention them.
    *   Provide an estimated total preparation and cooking time.

4.  **Nutritional Information (Optional - if capable, only provide estimates based on known values):** Provide an estimate of the nutritional information (calories, protein, fat, carbohydrates) per serving. Clearly state that this is an estimate. If you cannot reliably estimate, omit this section.

5.  **Serving Size:** Indicate the approximate number of servings the recipe yields.

6.  **Safety Notes (If applicable):** Add safety notes regarding safe handling of certain ingredients (e.g., "Wash hands thoroughly after handling raw chicken").

**III. Output Format:**

Present the recipe in a clear and organized format:""");
  late final GenerativeModel model;
  late final imagePart;


  // This method will be called when you get a response from your AI model
  void displayAIResponse(String responseText) {
    setState(() {
      _messages.add(ChatMessage(
        text: responseText,
        isUser: false,
        timestamp: DateTime.now(),
      ));
      _isTyping = false;
    });

    _scrollToBottom();
  }


  Future<File?> _pickImage() async {
    final ImagePicker picker = ImagePicker();

    try {
      // Step 1: Pick an image from the gallery
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        // imageQuality: 80, // Consider using this for smaller images
      );

      if (image != null) {
        // Step 2: Crop the selected image
        final CroppedFile? croppedFile = await ImageCropper().cropImage(
          sourcePath: image.path,
          aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
          // 1:1 aspect ratio
          compressQuality: 100,
          // Maintain high quality
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Crop Image',
              toolbarColor: Colors.deepOrange,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.square,
              lockAspectRatio: true, // Lock the aspect ratio to 1:1
            ),
            IOSUiSettings(
              title: 'Crop Image',
              aspectRatioLockEnabled: true, // Lock the aspect ratio to 1:1
            ),
          ],
        );

        if (croppedFile != null) {
          // Step 3: Convert CroppedFile to File
          return File(croppedFile.path); // Return the File object
        } else {
          // User canceled the cropping process
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Image cropping canceled.')),
            );
          }
          return null; // Return null to indicate cancellation
        }
      } else {
        // User canceled the picker
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No image selected.')),
          );
        }
        return null; // Return null to indicate cancellation
      }
    } catch (e) {
      // Error handling
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick or crop image: $e')),
        );
      }
      return null; // Return null to indicate an error
    }
  }

  void _handleSubmitted(String text) async {
    _textController.clear();

    if (text
        .trim()
        .isEmpty) return;

    // Add user message to chat
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isTyping = true;
    });

    _scrollToBottom();

    final prompt = userPrompt;
    final content = Content.multi([prompt, imagePart]);
    final response = await model.generateContent([content]);
    await Future.delayed(const Duration(seconds: 1));
    displayAIResponse(
        response.text!);
  }

  void _handleAttachImage() async {
    File? file = await _pickImage();
    final imageBytes = await file?.readAsBytes();
    imagePart = DataPart('image/jpg', imageBytes!);

    setState(() {
      _isTyping = true;
    });

    setState(() {
      _messages.add(ChatMessage(
        text: "Image attached",
        isUser: true,
        timestamp: DateTime.now(),
        isImage: true,
      ));
    });

    _scrollToBottom();

    // displayAIResponse("I\'m working on it");
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();
    // Add initial greeting message
    _messages.add(ChatMessage(
      text: 'Hello! I\'m your AI meal assistant. What kind of meal are you looking for today?',
      isUser: false,
      timestamp: DateTime.now(),
    ));
    model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: gemeni,
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AI Meal Recommendations',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.grey[50],
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length + (_isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length) {
                    return _buildTypingIndicator();
                  }
                  return _buildMessageBubble(_messages[index]);
                },
              ),
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) _buildAvatar(isUser),

          const SizedBox(width: 8),

          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? Colors.green : Colors.white,
                borderRadius: BorderRadius.circular(20).copyWith(
                  bottomLeft: isUser ? const Radius.circular(20) : const Radius.circular(0),
                  bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: isUser ? Colors.white : Colors.black87,
                  fontSize: 16,
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          if (isUser) _buildAvatar(isUser),
        ],
      ),
    );
  }

  Widget _buildAvatar(bool isUser) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isUser ? Colors.blue[700] : Colors.teal,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          isUser ? Icons.person : Icons.restaurant,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildAvatar(false),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20).copyWith(
                bottomLeft: const Radius.circular(0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: List.generate(3, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  height: 9,
                  width: 9,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.photo_camera),
              color: Colors.grey[600],
              onPressed: _isTyping ? null : _handleAttachImage,
            ),
            Expanded(
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(
                  hintText: 'Ask about meal recommendations...',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
                textCapitalization: TextCapitalization.sentences,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                onSubmitted: _isTyping ? null : _handleSubmitted,
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => _handleSubmitted(_textController.text),
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.green,
                disabledBackgroundColor: Colors.grey[400],
                disabledForegroundColor: Colors.white,
              ),
              child: const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }
}