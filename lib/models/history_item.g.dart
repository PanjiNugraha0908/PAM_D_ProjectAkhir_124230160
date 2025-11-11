// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HistoryItemAdapter extends TypeAdapter<HistoryItem> {
  @override
  final int typeId = 1;

  @override
  HistoryItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HistoryItem(
      username: fields[0] as String,
      countryName: fields[1] as String,
      flagUrl: fields[2] as String,
      capital: fields[3] as String,
      region: fields[4] as String,
      viewedAt: fields[5] as DateTime,
      isFavorite: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, HistoryItem obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.username)
      ..writeByte(1)
      ..write(obj.countryName)
      ..writeByte(2)
      ..write(obj.flagUrl)
      ..writeByte(3)
      ..write(obj.capital)
      ..writeByte(4)
      ..write(obj.region)
      ..writeByte(5)
      ..write(obj.viewedAt)
      ..writeByte(6)
      ..write(obj.isFavorite);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HistoryItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
