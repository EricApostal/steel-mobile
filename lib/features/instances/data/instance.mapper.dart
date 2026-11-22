// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'instance.dart';

class InstanceMapper extends ClassMapperBase<Instance> {
  InstanceMapper._();

  static InstanceMapper? _instance;
  static InstanceMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = InstanceMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'Instance';

  static String _$id(Instance v) => v.id;
  static const Field<Instance, String> _f$id = Field('id', _$id);
  static String _$name(Instance v) => v.name;
  static const Field<Instance, String> _f$name = Field('name', _$name);
  static String _$versionTag(Instance v) => v.versionTag;
  static const Field<Instance, String> _f$versionTag = Field(
    'versionTag',
    _$versionTag,
  );
  static int _$port(Instance v) => v.port;
  static const Field<Instance, int> _f$port = Field('port', _$port);
  static DateTime _$createdAt(Instance v) => v.createdAt;
  static const Field<Instance, DateTime> _f$createdAt = Field(
    'createdAt',
    _$createdAt,
  );

  @override
  final MappableFields<Instance> fields = const {
    #id: _f$id,
    #name: _f$name,
    #versionTag: _f$versionTag,
    #port: _f$port,
    #createdAt: _f$createdAt,
  };

  static Instance _instantiate(DecodingData data) {
    return Instance(
      id: data.dec(_f$id),
      name: data.dec(_f$name),
      versionTag: data.dec(_f$versionTag),
      port: data.dec(_f$port),
      createdAt: data.dec(_f$createdAt),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static Instance fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Instance>(map);
  }

  static Instance fromJson(String json) {
    return ensureInitialized().decodeJson<Instance>(json);
  }
}

mixin InstanceMappable {
  String toJson() {
    return InstanceMapper.ensureInitialized().encodeJson<Instance>(
      this as Instance,
    );
  }

  Map<String, dynamic> toMap() {
    return InstanceMapper.ensureInitialized().encodeMap<Instance>(
      this as Instance,
    );
  }

  InstanceCopyWith<Instance, Instance, Instance> get copyWith =>
      _InstanceCopyWithImpl<Instance, Instance>(
        this as Instance,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return InstanceMapper.ensureInitialized().stringifyValue(this as Instance);
  }

  @override
  bool operator ==(Object other) {
    return InstanceMapper.ensureInitialized().equalsValue(
      this as Instance,
      other,
    );
  }

  @override
  int get hashCode {
    return InstanceMapper.ensureInitialized().hashValue(this as Instance);
  }
}

extension InstanceValueCopy<$R, $Out> on ObjectCopyWith<$R, Instance, $Out> {
  InstanceCopyWith<$R, Instance, $Out> get $asInstance =>
      $base.as((v, t, t2) => _InstanceCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class InstanceCopyWith<$R, $In extends Instance, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? name,
    String? versionTag,
    int? port,
    DateTime? createdAt,
  });
  InstanceCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _InstanceCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, Instance, $Out>
    implements InstanceCopyWith<$R, Instance, $Out> {
  _InstanceCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Instance> $mapper =
      InstanceMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? name,
    String? versionTag,
    int? port,
    DateTime? createdAt,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (name != null) #name: name,
      if (versionTag != null) #versionTag: versionTag,
      if (port != null) #port: port,
      if (createdAt != null) #createdAt: createdAt,
    }),
  );
  @override
  Instance $make(CopyWithData data) => Instance(
    id: data.get(#id, or: $value.id),
    name: data.get(#name, or: $value.name),
    versionTag: data.get(#versionTag, or: $value.versionTag),
    port: data.get(#port, or: $value.port),
    createdAt: data.get(#createdAt, or: $value.createdAt),
  );

  @override
  InstanceCopyWith<$R2, Instance, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _InstanceCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

