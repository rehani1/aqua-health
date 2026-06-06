import 'package:hive/hive.dart';

part 'animal.g.dart'; // Name of the generated file

@HiveType(typeId: 0) // Unique ID for this class
class Animal extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String type;

  @HiveField(2)
  String sprite;

  @HiveField(3, defaultValue: false)
  bool isRare;

  Animal({required this.name, required this.type, required this.sprite, required this.isRare});
}
