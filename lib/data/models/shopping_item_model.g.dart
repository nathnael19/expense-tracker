// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shopping_item_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ShoppingItemModelAdapter extends TypeAdapter<ShoppingItemModel> {
  @override
  final int typeId = 8;

  @override
  ShoppingItemModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ShoppingItemModel(
      id: fields[0] as String,
      name: fields[1] as String,
      isCompleted: fields[2] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ShoppingItemModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.isCompleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShoppingItemModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
