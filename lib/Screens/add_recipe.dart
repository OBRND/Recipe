import 'package:flutter/material.dart';

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

  String? _imagePath;
  bool _includeCalories = false;

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
      // Save recipe data to database.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Recipe submitted successfully!')),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _pickImage() async {
    // Implement image picker here.
    setState(() {
      _imagePath = "path/to/image"; // Replace with actual image path.
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Share Your Recipe'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Rectangular Avatar for Image Selection
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                        image: _imagePath != null
                            ? DecorationImage(
                          image: AssetImage(_imagePath!),
                          fit: BoxFit.cover,
                        )
                            : null,
                      ),
                      child: _imagePath == null
                          ? Icon(Icons.camera_alt, size: 50, color: Colors.grey)
                          : null,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                // Recipe Name
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Recipe Name *',
                  ),
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Enter recipe name' : null,
                ),
                SizedBox(height: 16),
                // Ingredients
                Text(
                  'Ingredients *',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                ..._ingredients.map((ingredient) {
                  int index = _ingredients.indexOf(ingredient);
                  return Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(labelText: 'Name'),
                          onChanged: (value) => _ingredients[index]['name'] = value,
                          validator: (value) => value == null || value.isEmpty
                              ? 'Enter ingredient name'
                              : null,
                        ),
                      ),
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(labelText: 'Quantity'),
                          onChanged: (value) => _ingredients[index]['quantity'] = value,
                          validator: (value) => value == null || value.isEmpty
                              ? 'Enter quantity'
                              : null,
                        ),
                      ),
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(labelText: 'Unit'),
                          onChanged: (value) => _ingredients[index]['unit'] = value,
                        ),
                      ),
                    ],
                  );
                }),
                TextButton.icon(
                  onPressed: _addIngredient,
                  icon: Icon(Icons.add),
                  label: Text('Add Ingredient'),
                ),
                SizedBox(height: 16),
                // Procedures
                Text(
                  'Procedure Steps *',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                ..._procedures.asMap().entries.map((entry) {
                  int index = entry.key;
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Step ${index + 1}: '),
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(labelText: 'Enter procedure'),
                          onChanged: (value) => _procedures[index] = value,
                          validator: (value) =>
                          value == null || value.isEmpty ? 'Enter procedure' : null,
                        ),
                      ),
                    ],
                  );
                }),
                TextButton.icon(
                  onPressed: _addProcedureStep,
                  icon: Icon(Icons.add),
                  label: Text('Add Step'),
                ),
                SizedBox(height: 16),
                // Cooking Time
                TextFormField(
                  controller: _cookingTimeController,
                  decoration: InputDecoration(labelText: 'Cooking Time (minutes) *'),
                  keyboardType: TextInputType.number,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Enter cooking time'
                      : null,
                ),
                SizedBox(height: 16),
                // Include Calories
                Row(
                  children: [
                    Text('Include Calories?'),
                    Radio<bool>(
                      value: true,
                      groupValue: _includeCalories,
                      onChanged: (value) {
                        setState(() {
                          _includeCalories = value!;
                        });
                      },
                    ),
                    Text('Yes'),
                    Radio<bool>(
                      value: false,
                      groupValue: _includeCalories,
                      onChanged: (value) {
                        setState(() {
                          _includeCalories = value!;
                        });
                      },
                    ),
                    Text('No'),
                    if (_includeCalories)
                      SizedBox(
                        width: 100,
                        child: TextFormField(
                          controller: _caloriesController,
                          decoration: InputDecoration(labelText: 'Calories'),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 16),
                // Video Link
                TextFormField(
                  controller: _videoLinkController,
                  decoration: InputDecoration(labelText: 'Video Link (optional)'),
                ),
                SizedBox(height: 32),
                // Submit Button
                Center(
                  child: ElevatedButton(
                    onPressed: _saveForm,
                    child: Text('Submit Recipe'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
