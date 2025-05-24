// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'orca.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OrcaSpecAdapter extends TypeAdapter<OrcaSpec> {
  @override
  final int typeId = 0;

  @override
  OrcaSpec read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OrcaSpec(
      appName: fields[0] as String,
      path: fields[1] as String,
      engine: fields[2] as String,
      services: (fields[3] as List).cast<ServiceComponent>(),
    );
  }

  @override
  void write(BinaryWriter writer, OrcaSpec obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.appName)
      ..writeByte(1)
      ..write(obj.path)
      ..writeByte(2)
      ..write(obj.engine)
      ..writeByte(3)
      ..write(obj.services);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrcaSpecAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EngineComponentAdapter extends TypeAdapter<EngineComponent> {
  @override
  final int typeId = 2;

  @override
  EngineComponent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EngineComponent(
      version: fields[0] as String,
      path: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, EngineComponent obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.version)
      ..writeByte(1)
      ..write(obj.path);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EngineComponentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ServiceComponentAdapter extends TypeAdapter<ServiceComponent> {
  @override
  final int typeId = 1;

  @override
  ServiceComponent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ServiceComponent(
      name: fields[0] as String,
      version: fields[1] as String,
      permissionEntries: (fields[2] as List).cast<ServicePermissionEntry>(),
    );
  }

  @override
  void write(BinaryWriter writer, ServiceComponent obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.version)
      ..writeByte(2)
      ..write(obj.permissionEntries);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServiceComponentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ServicePermissionEntryAdapter
    extends TypeAdapter<ServicePermissionEntry> {
  @override
  final int typeId = 4;

  @override
  ServicePermissionEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ServicePermissionEntry(
      fields[0] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ServicePermissionEntry obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.permId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServicePermissionEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class OrcaRuntimeAdapter extends TypeAdapter<OrcaRuntime> {
  @override
  final int typeId = 3;

  @override
  OrcaRuntime read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OrcaRuntime(
      orcaSpec: fields[0] as OrcaSpec,
      appName: fields[1] as String,
      engineVersion: fields[2] as String,
      services: (fields[3] as List)
          .map((dynamic e) => (e as Map).cast<String, dynamic>())
          .toList(),
    );
  }

  @override
  void write(BinaryWriter writer, OrcaRuntime obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.orcaSpec)
      ..writeByte(1)
      ..write(obj.appName)
      ..writeByte(2)
      ..write(obj.engineVersion)
      ..writeByte(3)
      ..write(obj.services)
      ..writeByte(4)
      ..write(obj.logs)
      ..writeByte(5)
      ..write(obj.subprocesses)
      ..writeByte(6)
      ..write(obj.subprocLogs);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrcaRuntimeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
