import 'dart:developer';
import 'dart:ffi';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meal/Models/decoration.dart';
import 'package:meal/Models/user_id.dart';
import 'package:meal/Screens/ideas/add_recipe.dart';
import 'package:meal/Screens/ideas/favorites.dart';
import 'package:meal/Screens/ideas/my_recipes.dart';
import 'package:provider/provider.dart';

import '../../DataBase/storage.dart';
import '../../Keys.dart';
import 'new_recipes.dart';

class IdeasTab extends StatefulWidget {
  const IdeasTab({super.key});

  @override
  State<IdeasTab> createState() => _IdeasTabState();
}

class _IdeasTabState extends State<IdeasTab> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin  {

  bool get wantKeepAlive => true; // Keeps the state alive
  final PageStorageBucket _bucket = PageStorageBucket();
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  bool _showFloatingButton = true;
  static const Color accentColor = Color(0xDBF32607);
  final ValueNotifier<bool> _showFloatingButtonNotifier = ValueNotifier(true);
  late final GenerativeModel model;
  late File _selectedImage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _scrollController.addListener(_scrollListener);
    model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: gemeni,
    );
  }

  void _scrollListener() {
    if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
      if (_showFloatingButtonNotifier.value) {
        _showFloatingButtonNotifier.value = false;
      }
    } else {
      if (!_showFloatingButtonNotifier.value) {
        _showFloatingButtonNotifier.value = true;
      }
    }
  }


  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserID>(context);
    super.build(context);
    return Scaffold(
        body: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (context, innerBoxIsScrolled) =>
          [
            SliverAppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              floating: true,
              pinned: true,
              title: const Text(
                'Recipe Ideas',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.black87),
                  onPressed: () {
                    // Implement search functionality
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.filter_list, color: Colors.black87),
                  onPressed: () {
                    // Implement filter functionality
                  },
                ),
              ],
              bottom: TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: accentColor,
                // unselectedLabelColor: Colors.grey[600],
                // indicatorColor: Colors.orange[700],
                tabs: const [
                  Tab(text: 'For You'),
                  Tab(text: 'New & Trending'),
                  Tab(text: 'Community Favorites'),
                  Tab(text: 'My Recipes'),
                  Tab(text: 'Kid-Friendly'),
                  Tab(text: 'Quick Meals')
                ],
              ),
            ),
          ],
          body: TabBarView(
            controller: _tabController,
            children: [
              _forYouTab(),
              _newTab(user.uid),
              _buildCommunityFavoritesTab(user.uid),
              _mineTab(user.uid),
              _buildKidFriendlyTab(),
              _buildQuickMealsTab()
            ],
          ),
        ),
        floatingActionButton: ValueListenableBuilder<bool>(
            valueListenable: _showFloatingButtonNotifier,
            builder: (context, isVisible, child) {
              return AnimatedSlide(
                duration: const Duration(milliseconds: 300),
                offset: isVisible ? Offset.zero : const Offset(0, 2),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: isVisible ? 1 : 0,
                  child: FloatingActionButton.extended(
                    label: Container(
                      width: 120,
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(right: 6),
                            child: Icon(Icons.add, color: Colors.white),
                          ),
                          Text('Share recipe', style: TextStyle(
                              color: Colors.white
                          ),)
                        ],
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => AddRecipeScreen()));
                    },
                  )
                ),

              );
            }
            )
    );
  }

  Widget _forYouTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildWeeklyMealPlanCard(),
        const SizedBox(height: 24),
        _buildTrendingForYouSection(),
        const SizedBox(height: 24),
        _buildPersonalizedSuggestions(),
      ],
    );
  }

  Widget _buildWeeklyMealPlanCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: [accentColor, Colors.orange[600]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This Week\'s Meal Plan',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Personalized for your family',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                  File? file = await _pickImage();
                final imageBytes = await file?.readAsBytes();
                print('[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]');
                final imagePart = DataPart('image/jpg', imageBytes!);
                // print(imageBytes.isNotEmpty);
                final prompt = TextPart("""
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
                final content = Content.multi([prompt, imagePart]);
                final response = await model.generateContent([content]);

                log("${response.text}");
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.orange[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('View Plan'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingForYouSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Trending For You',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 220,
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            itemBuilder: (context, index) => _buildTrendingCard(),
          ),
        ),
      ],
    );
  }

  Widget _buildTrendingCard() {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                'https://images.unsplash.com/photo-1546069901-ba9599a7e63c',
                height: 120,
                width: 120,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Healthy Salad Bowl',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.timer_outlined, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '25 min',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalizedSuggestions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Based on Your Preferences',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to all suggestions
              },
              child: Text(
                'See All',
                style: TextStyle(color: Colors.orange[700]),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          itemBuilder: (context, index) => _buildSuggestionCard({"name": 'Pizza'}),
        ),
      ],
    );
  }

  Widget _buildSuggestionCard(meal) {
      return InkWell(
        onTap: () {
        },
        child: Container(
          height: MediaQuery.sizeOf(context).width / 2.8,
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: Stack(
              children: [
                Container(
                  height: MediaQuery.sizeOf(context).width / 3.2,
                  child: Container(
                    decoration: boxDecoration,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: MediaQuery.sizeOf(context).width / 3,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment
                                .start,
                            children: [
                              Text(
                                meal['name'],
                                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                    fontSize: 16
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Perfect for family dinner',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.star, size: 16,
                                      color: Colors.orange[700]),
                                  const SizedBox(width: 4),
                                  Text(
                                    '4.8',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Icon(Icons.timer_outlined,
                                      size: 16,
                                      color: Colors.grey[600]),
                                  const SizedBox(width: 4),
                                  Text(
                                    '45 min',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  elevation: 5,
                  margin: EdgeInsets.all(0),
                  child: Container(
                    width: MediaQuery
                        .sizeOf(context)
                        .width / 2.8,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(
                          12)),
                      image: DecorationImage(
                        fit: BoxFit.fitWidth,
                        image: NetworkImage(
                            'https://www.onehappydish.com/wp-content/uploads/2023/11/scrambled-eggs-with-cream-cheese-recipe.jpg'),
                      ),
                    ),
                  ),
                ),
              ]
          ),
        ),
      );

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
          aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1), // 1:1 aspect ratio
          compressQuality: 100, // Maintain high quality
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

  // Other tab building methods would follow similar patterns
  Widget _buildCommunityFavoritesTab(String uid) {
    return Center(child:  CommunityFavorites(uid: uid));
  }

  Widget _newTab(String uid) {
    return Center(child: NewRecipes(uid: uid));
  }

  Widget _mineTab(String uid) {
    return Center(child: MyContributionsScreen(uid: uid));
  }

  Widget _buildKidFriendlyTab() {
    return const Center(child: Text('Kid-Friendly'));
  }

  Widget _buildQuickMealsTab() {
    return const Center(child: Text('Quick Meals'));
  }
}