// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schema_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The bundled JSON Schema named [name] (e.g. `config.schema.json`), or null
/// if there is none. Schemas are snapshots of Steel's published ones.

@ProviderFor(tomlSchema)
final tomlSchemaProvider = TomlSchemaFamily._();

/// The bundled JSON Schema named [name] (e.g. `config.schema.json`), or null
/// if there is none. Schemas are snapshots of Steel's published ones.

final class TomlSchemaProvider
    extends
        $FunctionalProvider<
          AsyncValue<SchemaNode?>,
          SchemaNode?,
          FutureOr<SchemaNode?>
        >
    with $FutureModifier<SchemaNode?>, $FutureProvider<SchemaNode?> {
  /// The bundled JSON Schema named [name] (e.g. `config.schema.json`), or null
  /// if there is none. Schemas are snapshots of Steel's published ones.
  TomlSchemaProvider._({
    required TomlSchemaFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'tomlSchemaProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tomlSchemaHash();

  @override
  String toString() {
    return r'tomlSchemaProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<SchemaNode?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SchemaNode?> create(Ref ref) {
    final argument = this.argument as String;
    return tomlSchema(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TomlSchemaProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tomlSchemaHash() => r'2345d4be0caea6132d49fb48104d54afb05b596d';

/// The bundled JSON Schema named [name] (e.g. `config.schema.json`), or null
/// if there is none. Schemas are snapshots of Steel's published ones.

final class TomlSchemaFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<SchemaNode?>, String> {
  TomlSchemaFamily._()
    : super(
        retry: null,
        name: r'tomlSchemaProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// The bundled JSON Schema named [name] (e.g. `config.schema.json`), or null
  /// if there is none. Schemas are snapshots of Steel's published ones.

  TomlSchemaProvider call(String name) =>
      TomlSchemaProvider._(argument: name, from: this);

  @override
  String toString() => r'tomlSchemaProvider';
}
