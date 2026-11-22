import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/toml/json_schema.dart';
import '../data/toml/toml_document.dart';

part 'schema_providers.g.dart';

/// The bundled JSON Schema named [name] (e.g. `config.schema.json`), or null
/// if there is none. Schemas are snapshots of Steel's published ones.
@Riverpod(keepAlive: true)
Future<SchemaNode?> tomlSchema(Ref ref, String name) async {
  if (!RegExp(r'^[a-z_]+\.schema\.json$').hasMatch(name)) return null;
  try {
    final json = jsonDecode(await rootBundle.loadString('assets/schemas/$name'));
    return SchemaNode.root(json as Map<String, dynamic>);
  } catch (_) {
    return null;
  }
}

/// Which bundled schema applies: the file's own `#:schema` header if it has
/// one, else `<file name>.schema.json`.
String schemaNameFor(TomlDocument document, String fileName) {
  final fromHeader = document.schemaUrl?.split('/').last;
  if (fromHeader != null && fromHeader.endsWith('.schema.json')) return fromHeader;
  return '${fileName.replaceFirst(RegExp(r'\.toml$'), '')}.schema.json';
}
