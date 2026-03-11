import 'package:hive/hive.dart';

part 'person_model.g.dart';

@HiveType(typeId: 9)
class PersonModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final DateTime createdAt;

  PersonModel({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  PersonModel copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
  }) {
    return PersonModel(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
