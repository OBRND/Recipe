import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meal/Models/decoration.dart';
import 'package:provider/provider.dart';
import '../../DataBase/storage.dart';
import '../../DataBase/write_db.dart';
import '../../Models/user_id.dart';

class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({super.key});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {

  final _formKey = GlobalKey<FormState>();
  final List<Map<String, dynamic>> _ingredients = [];
  final List<String> _procedures = ['', '', ''];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cookingTimeController = TextEditingController();
  final TextEditingController _videoLinkController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  final Set<String> _selectedTags = {};
  String _selectedMealType = 'Dinner';
  final Set<String> _selectedPreferences = {};
  File? _selectedImage;
  bool _includeCalories = false;
  bool _includePreferences = false;

  // Predefined lists
  final List<String> _mealTypes = [
    'Breakfast',
    'Lunch',
    'Dinner',
    'Snack',
    'Dessert',
    'Beverage'
  ];

  final List<String> _availableTags = [
    'Quick & Easy',
    'Healthy',
    'Budget-Friendly',
    'Spicy',
    'Kid-Friendly',
    'Party',
    'Comfort Food'
  ];

  final List<String> _dietaryPreferences = [
    'Vegetarian',
    'Vegan',
    'Gluten-Free',
    'Dairy-Free',
    'Keto',
    'Paleo',
    'Low-Carb',
    'Halal',
    'Kosher'
  ];

  void _addIngredient() {
    setState(() {
      _ingredients.add({'name': '', 'quantity': '', 'unit': ''});
    });
  }

  void _addProcedureStep() {
    setState(() {
      _procedures.add('');
    });
  }

  void _saveForm() {
    String? errorMessage;

    if (_selectedTags.isEmpty) {
      errorMessage = 'Pick at least 1 tag that applies in the tags section.';
    } else if (_includePreferences && _selectedPreferences.isEmpty) {
      errorMessage = 'Pick at least 1 dietary preference.';
    }

    if (_formKey.currentState!.validate()) {
      if (_ingredients.isEmpty || _ingredients.length < 3) {
        errorMessage = 'Please add at least three ingredient.';
      }
      if (_procedures.isEmpty || _procedures.every((step) =>
      step
          .trim()
          .isEmpty || _procedures.length < 3)) {
        errorMessage = 'Please add at least a three step procedure.';
      }

      if (errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
        return; // Stop form submission
      }

      submitRecipe();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.grey[300],
            content: const Row(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Icon(Icons.check, color: Colors.green,),
                ),
                Text('Recipe submitted successfully!'),
              ],
            )),
      );
      Navigator.pop(context);
    }
  }


  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    try {
      // Step 1: Pick an image from the gallery
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        // imageQuality: 80, // Compress the image to 80% quality
      );

      if (image != null) {
        // Step 2: Crop the selected image
        final CroppedFile? croppedFile = await ImageCropper().cropImage(
          sourcePath: image.path,
          aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1), // 1:1 aspect ratio
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
          final File croppedImageFile = File(croppedFile.path);

          // Step 4: Update the state with the cropped image
          setState(() {
            _selectedImage = croppedImageFile; // Use the cropped image
          });
        } else {
          // User canceled the cropping process
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image cropping canceled.')),
          );
        }
      } else {
        // User canceled the picker
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No image selected.')),
        );
      }
    } catch (e) {
      // Error handling
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick or crop image: $e')),
      );
    }
  }


  Widget _buildRequiredLabel(String label) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: label,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          TextSpan(
            text: ' *',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Your Recipe'),
        elevation: 1,
      ),
      body: Container(
        color: Colors.grey[50],
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Selection
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: _selectedImage == null
                            ?
                        Column (
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt,
                                size: 50, color: Colors.grey[400]),
                            const SizedBox(height: 8),
                            Text('Add Photo',
                                style: TextStyle(color: Colors.grey[400])),
                          ],
                        )
                            : _selectedImage != null
                            ? Image.file(
                          _selectedImage!,
                          width: 200,
                          height: 200,
                          fit: BoxFit.fill,
                        )
                            : const Text('No image selected'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Recipe Name
                  _buildRequiredLabel('Recipe Name'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    decoration: textinputdecoration.copyWith(
                      hintText: 'Enter recipe name',
                    ),
                    validator: (value) =>
                    value?.isEmpty ?? true ? 'Enter recipe name' : null,
                  ),
                  const SizedBox(height: 24),

                  // Meal Type Selection
                  _buildRequiredLabel('Meal Type'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: boxDecoration,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedMealType,
                        isExpanded: true,
                        dropdownColor: Color(0xfff6efef),
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        items: _mealTypes.map((String type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedMealType = newValue!;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Tags
                  _buildRequiredLabel('Tags'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _availableTags.map((tag) {
                      final isSelected = _selectedTags.contains(tag);
                      return FilterChip(
                        label: Text(tag),
                        selected: isSelected,
                        onSelected: (bool selected) {

                          setState(() {
                            if (selected && _selectedTags.length < 3) {
                              _selectedTags.add(tag);
                            } else {
                              _selectedTags.remove(tag);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Dietary Preferences Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Include Dietary Preferences?',
                                  style: TextStyle(fontSize: 16)),
                              const SizedBox(width: 16),
                              Switch(
                                value: _includePreferences,
                                onChanged: (value) {
                                  setState(() {
                                    _includePreferences = value;
                                  });
                                },
                                activeColor: Color(0xDBF32607),
                              ),
                            ],
                          ),
                          if (_includePreferences) ...[
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _dietaryPreferences.map((pref) {
                                final isSelected =
                                _selectedPreferences.contains(pref);
                                return FilterChip(
                                  label: Text(pref),
                                  selected: isSelected,
                                  onSelected: (bool selected) {
                                    setState(() {
                                      if (selected && _selectedPreferences.length < 3) {
                                        _selectedPreferences.add(pref);
                                      } else {
                                        _selectedPreferences.remove(pref);
                                      }
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Ingredients
                  _buildRequiredLabel('Ingredients'),
                  const SizedBox(height: 8),
                  Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      children: [
                        ..._ingredients.map((ingredient) {
                      int index = _ingredients.indexOf(ingredient);
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal:  8.0),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Name',
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                onChanged: (value) =>
                                _ingredients[index]['name'] = value,
                                validator: (value) => value?.isEmpty ?? true
                                    ? 'Enter ingredient name'
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Quantity',
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                onChanged: (value) =>
                                _ingredients[index]['quantity'] = value,
                                validator: (value) => value?.isEmpty ?? true
                                    ? 'Enter quantity'
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Unit',
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                onChanged: (value) =>
                                _ingredients[index]['unit'] = value,
                                validator: (value) => value?.isEmpty ?? true
                                    ? 'Enter Unit'
                                    : null,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.remove_circle, color: Colors.red),
                              onPressed: () {
                                _ingredients.removeAt(index);
                                setState(() {});
                              },
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                      ]
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _addIngredient,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Ingredient', style: TextStyle(color: Color(0xDBF32607))),
                  ),
                  const SizedBox(height: 24),

                  // Procedures
                  _buildRequiredLabel('Procedure Steps'),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Column(
                        children: _procedures.asMap().entries.map((entry) {
                          int index = entry.key;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    decoration: textinputdecoration.copyWith(
                                      hintText: 'Step ${index + 1}'
                                    ),
                                    onChanged: (value) => _procedures[index] = value,
                                    validator: (value) => value?.isEmpty ?? true ? 'Enter step ${index + 1}' : null,
                                    maxLines: 2,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                                  onPressed: () {
                                    _procedures.removeAt(index);
                                    setState(() {});
                                  },
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _addProcedureStep,
                    icon: const Icon(Icons.add,),
                    label: const Text('Add Step',
                        style: TextStyle(color: Color(0xDBF32607))),
                  ),
                  const SizedBox(height: 24),

                  // Cooking Time
                  _buildRequiredLabel('Cooking Time'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _cookingTimeController,
                    decoration:  textinputdecoration.copyWith(
                      hintText: 'Enter cooking time in minutes'
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                    value?.isEmpty ?? true ? 'Enter cooking time' : null,
                  ),
                  const SizedBox(height: 24),

                  // Calories Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Include Calories?',
                                  style: TextStyle(fontSize: 16)),
                              const SizedBox(width: 16),
                              Switch(
                                value: _includeCalories,
                                onChanged: (value) {
                                  setState(() {
                                    _includeCalories = value;
                                  });
                                  print(_ingredients);
                                  print(_procedures);
                                },
                                activeColor: Color(0xDBF32607),
                              ),
                            ],
                          ),
                          if (_includeCalories) ...[
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _caloriesController,
                              decoration: textinputdecoration.copyWith(
                                labelText: 'Calories',
                              ),
                              validator: (value) {
                                if (_includeCalories && _caloriesController.text.isEmpty) {
                                  return 'Enter a value for calories';
                                }
                                return null;
                              },
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Video Link
                  const Text(
                    'Video Link (optional)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _videoLinkController,
                    decoration: textinputdecoration.copyWith(
                      hintText: 'Video Link',
                    ),
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: ElevatedButton(
                      onPressed: _saveForm,
                      child: const Text('Submit Recipe'),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void submitRecipe() async {
    final user = Provider.of<UserID>(context, listen: false);
    Write write = Write(uid: user.uid);
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image!')),
      );
      return;
    }

    try {
      final imageUrl = await uploadImage(_selectedImage!);
      if (imageUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image upload failed!')),
        );
        return;
      }

      // Step 2: Save recipe details to Firestore
      await write.saveRecipeDetails(
        name: _nameController.text,
        ingredients: _ingredients,
        procedure: _procedures,
        tags: _selectedTags,
        imageUrl: imageUrl,
        mealType: _selectedMealType,
        cookingTime: _cookingTimeController.text,
        selectedPreferences:  _includePreferences == true ? _selectedPreferences: null,
        calories:  _includeCalories == true ? _caloriesController.text: null,
        videoUrl: _videoLinkController.text.isNotEmpty ?  _videoLinkController.text : null
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Recipe uploaded successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,),
      );

      setState(() {
        _selectedImage = null;
        _nameController.clear();
        _cookingTimeController.clear();
        _videoLinkController.clear();
        _caloriesController.clear();
      });
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload recipe: $e')),
      );
    }
  }

}