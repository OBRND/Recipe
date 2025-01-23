import 'package:hive/hive.dart';

part 'recipe_hive.g.dart';

@HiveType(typeId: 0)
class Recipe extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String? imagePath;
  @HiveField(3)
  final DateTime lastUpdated;

  Recipe({
    required this.id,
    required this.name,
    this.imagePath,
    required this.lastUpdated,
  });
}
