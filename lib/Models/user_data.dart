import 'package:hive/hive.dart';

part 'user_data.g.dart';

@HiveType(typeId: 0) // Assign a unique typeId
class UserDataModel {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final List<dynamic> savedRecipes;

  @HiveField(2)
  final List<dynamic> recentRecipes;

  @HiveField(3)
  final List<dynamic> children;

  @HiveField(4)
  final bool custom;

  @HiveField(5)
  final int swapped;

  UserDataModel({
    required this.name,
    required this.savedRecipes,
    required this.recentRecipes,
    required this.children,
    required this.custom,
    required this.swapped,
  });

  factory UserDataModel.fromMap(Map<String, dynamic> data) {
    return UserDataModel(
      name: data['name'] ?? '',
      savedRecipes: List<String>.from(data['savedRecipes'] ?? []),
      recentRecipes: List<String>.from(data['recent'] ?? []),
      children: List.from(data['children'] ?? ['adults']),
      custom: data['custom'] ?? false,
      swapped: data['swapped'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'savedRecipes': savedRecipes,
      'recentRecipes': recentRecipes,
      'children': children,
      'custom': custom,
      'swapped': swapped,
    };
  }
}
