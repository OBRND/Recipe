import 'package:flutter/material.dart';
import 'package:meal/Models/decoration.dart';

class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({super.key});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<Map<String, dynamic>> _ingredients = [];
  final List<String> _procedures = [''];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cookingTimeController = TextEditingController();
  final TextEditingController _videoLinkController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  final Set<String> _selectedTags = {};
  String _selectedMealType = 'Dinner';
  final Set<String> _selectedDietaryPreferences = {};

  String? _imagePath;
  bool _includeCalories = false;
  bool _includeDietaryPreferences = false;

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
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recipe submitted successfully!')),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _pickImage() async {
    // Implement image picker here
    setState(() {
      _imagePath = "path/to/image";
    });
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
              color: Colors.orange[700],
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
                          image: _imagePath != null
                              ? DecorationImage(
                            image: AssetImage(_imagePath!),
                            fit: BoxFit.cover,
                          )
                              : null,
                        ),
                        child: _imagePath == null
                            ?
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt,
                                size: 50, color: Colors.grey[400]),
                            const SizedBox(height: 8),
                            Text('Add Photo',
                                style: TextStyle(color: Colors.grey[400])),
                          ],
                        )
                            : null,
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
                    padding: const EdgeInsets.symmetric(horizontal: 12),
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
                            children: [
                              const Text('Include Dietary Preferences?',
                                  style: TextStyle(fontSize: 16)),
                              const SizedBox(width: 16),
                              Switch(
                                value: _includeDietaryPreferences,
                                onChanged: (value) {
                                  setState(() {
                                    _includeDietaryPreferences = value;
                                  });
                                },
                                activeColor: Color(0xDBF32607),
                              ),
                            ],
                          ),
                          if (_includeDietaryPreferences) ...[
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _dietaryPreferences.map((pref) {
                                final isSelected =
                                _selectedDietaryPreferences.contains(pref);
                                return FilterChip(
                                  label: Text(pref),
                                  selected: isSelected,
                                  onSelected: (bool selected) {
                                    setState(() {
                                      if (selected && _selectedDietaryPreferences.length < 3) {
                                        _selectedDietaryPreferences.add(pref);
                                      } else {
                                        _selectedDietaryPreferences.remove(pref);
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
                  ..._ingredients.map((ingredient) {
                    int index = _ingredients.indexOf(ingredient);
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  TextButton.icon(
                    onPressed: _addIngredient,
                    icon: const Icon(Icons.add, color: Colors.orange),
                    label: const Text('Add Ingredient',
                        style: TextStyle(color: Colors.orange)),
                  ),
                  const SizedBox(height: 24),

                  // Procedures
                  _buildRequiredLabel('Procedure Steps'),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: _procedures.asMap().entries.map((entry) {
                          int index = entry.key;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    decoration: InputDecoration(hintText: 'Step ${index + 1}', filled: true),
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
                    icon: const Icon(Icons.add, color: Colors.orange),
                    label: const Text('Add Step',
                        style: TextStyle(color: Colors.orange)),
                  ),
                  const SizedBox(height: 24),

                  // Cooking Time
                  _buildRequiredLabel('Cooking Time'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _cookingTimeController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Enter cooking time in minutes',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                    value?.isEmpty ?? true ? 'Enter cooking time' : null,
                  ),
                  const SizedBox(height: 24),

                  // Calories Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
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
                                },
                                activeColor: Colors.orange,
                              ),
                            ],
                          ),
                          if (_includeCalories) ...[
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _caloriesController,
                              decoration: InputDecoration(
                                labelText: 'Calories per serving',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
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
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Enter video URL',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Submit Button
                  Center(
                    child: ElevatedButton(
                      onPressed: _saveForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 48, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Submit Recipe',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
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
}