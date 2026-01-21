// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shortcut_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ShortcutModelAdapter extends TypeAdapter<ShortcutModel> {
  @override
  final int typeId = 2;

  @override
  ShortcutModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ShortcutModel(
      id: fields[0] as String,
      title: fields[1] as String,
      amount: fields[2] as double,
      categoryId: fields[3] as String,
      note: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ShortcutModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.categoryId)
      ..writeByte(4)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShortcutModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
