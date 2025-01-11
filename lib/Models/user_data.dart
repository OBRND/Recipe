class UserDataModel {
  final String name;
  final List<dynamic> savedRecipes;
  final List<dynamic> recentRecipes;
  final List<dynamic> children;
  final bool custom;


  UserDataModel({
    required this.name,
    required this.savedRecipes,
    required this.recentRecipes,
    required this.children,
    required this.custom,
  });


  factory UserDataModel.fromMap(Map<String, dynamic> data) {
    return UserDataModel(
      name: data['name'] ?? '',
      savedRecipes: List<String>.from(data['savedRecipes'] ?? []),
      recentRecipes: List<String>.from(data['recent'] ?? []),
      children: List.from(data['children'] ?? ['adults']),
      custom: data['custom'] ?? false,
    );
  }
}


