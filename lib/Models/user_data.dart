class UserDataModel {
  final String name;
  final List<dynamic> savedRecipes;
  final List<dynamic> recentRecipes;

  UserDataModel({
    required this.name,
    required this.savedRecipes,
    required this.recentRecipes,
  });

  factory UserDataModel.fromMap(Map<String, dynamic> data) {
    return UserDataModel(
      name: data['name'] ?? '',
      savedRecipes: List<String>.from(data['savedRecipes'] ?? []),
      recentRecipes: List<String>.from(data['recent'] ?? []),
    );
  }
}


