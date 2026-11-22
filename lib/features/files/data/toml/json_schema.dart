/// A read-only view of the subset of JSON Schema that Steel's config schemas
/// use: types, enums, ranges, defaults, descriptions, nested objects, arrays
/// and local `$ref`s.
class SchemaNode {
  const SchemaNode._(this._raw, this._root);

  factory SchemaNode.root(Map<String, dynamic> json) => SchemaNode._(json, json);

  final Map<String, dynamic> _raw;
  final Map<String, dynamic> _root;

  /// This node with any `$ref` followed (sibling keys override the target's).
  Map<String, dynamic> get _n {
    final ref = _raw[r'$ref'];
    if (ref is! String || !ref.startsWith('#/')) return _raw;
    Object? target = _root;
    for (final part in ref.substring(2).split('/')) {
      target = target is Map ? target[part] : null;
    }
    if (target is! Map<String, dynamic>) return _raw;
    return {...target, ..._raw}..remove(r'$ref');
  }

  String? get type {
    final t = _n['type'];
    if (t is String) return t;
    if (t is List) return t.whereType<String>().where((x) => x != 'null').firstOrNull;
    return null;
  }

  String? get description => _n['description'] as String?;
  Object? get defaultValue => _n['default'];
  num? get minimum => _n['minimum'] as num?;
  num? get maximum => _n['maximum'] as num?;
  String? get format => _n['format'] as String?;

  List<Object?>? get enumValues => (_n['enum'] as List?)?.cast<Object?>();

  Set<String> get required => {...?(_n['required'] as List?)?.cast<String>()};

  Map<String, SchemaNode> get properties => {
        for (final e in ((_n['properties'] as Map?) ?? const {}).entries)
          e.key as String: SchemaNode._(e.value as Map<String, dynamic>, _root),
      };

  /// Schema for arbitrary extra keys (e.g. `groups.<name>`), if it is one.
  SchemaNode? get additionalProperties {
    final a = _n['additionalProperties'];
    return a is Map<String, dynamic> ? SchemaNode._(a, _root) : null;
  }

  SchemaNode? get items {
    final i = _n['items'];
    return i is Map<String, dynamic> ? SchemaNode._(i, _root) : null;
  }

  /// The schema for key [name]: a declared property, else a map value.
  SchemaNode? child(String name) => properties[name] ?? additionalProperties;

  /// The schema of the table at [path] (array elements resolve to `items`).
  SchemaNode? at(List<String> path) {
    SchemaNode? node = this;
    for (final segment in path) {
      node = node?.child(segment);
      if (node != null && node.type == 'array') node = node.items;
    }
    return node;
  }
}
