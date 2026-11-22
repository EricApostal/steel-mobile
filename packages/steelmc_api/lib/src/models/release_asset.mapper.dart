// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'release_asset.dart';

class ReleaseAssetMapper extends ClassMapperBase<ReleaseAsset> {
  ReleaseAssetMapper._();

  static ReleaseAssetMapper? _instance;
  static ReleaseAssetMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ReleaseAssetMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'ReleaseAsset';

  static int _$id(ReleaseAsset v) => v.id;
  static const Field<ReleaseAsset, int> _f$id = Field('id', _$id);
  static String _$name(ReleaseAsset v) => v.name;
  static const Field<ReleaseAsset, String> _f$name = Field('name', _$name);
  static int _$size(ReleaseAsset v) => v.size;
  static const Field<ReleaseAsset, int> _f$size = Field('size', _$size);
  static String _$browserDownloadUrl(ReleaseAsset v) => v.browserDownloadUrl;
  static const Field<ReleaseAsset, String> _f$browserDownloadUrl = Field(
    'browserDownloadUrl',
    _$browserDownloadUrl,
    key: r'browser_download_url',
  );
  static String? _$digest(ReleaseAsset v) => v.digest;
  static const Field<ReleaseAsset, String> _f$digest = Field(
    'digest',
    _$digest,
    opt: true,
  );
  static int _$downloadCount(ReleaseAsset v) => v.downloadCount;
  static const Field<ReleaseAsset, int> _f$downloadCount = Field(
    'downloadCount',
    _$downloadCount,
    key: r'download_count',
    opt: true,
    def: 0,
  );

  @override
  final MappableFields<ReleaseAsset> fields = const {
    #id: _f$id,
    #name: _f$name,
    #size: _f$size,
    #browserDownloadUrl: _f$browserDownloadUrl,
    #digest: _f$digest,
    #downloadCount: _f$downloadCount,
  };

  static ReleaseAsset _instantiate(DecodingData data) {
    return ReleaseAsset(
      id: data.dec(_f$id),
      name: data.dec(_f$name),
      size: data.dec(_f$size),
      browserDownloadUrl: data.dec(_f$browserDownloadUrl),
      digest: data.dec(_f$digest),
      downloadCount: data.dec(_f$downloadCount),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ReleaseAsset fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ReleaseAsset>(map);
  }

  static ReleaseAsset fromJson(String json) {
    return ensureInitialized().decodeJson<ReleaseAsset>(json);
  }
}

mixin ReleaseAssetMappable {
  String toJson() {
    return ReleaseAssetMapper.ensureInitialized().encodeJson<ReleaseAsset>(
      this as ReleaseAsset,
    );
  }

  Map<String, dynamic> toMap() {
    return ReleaseAssetMapper.ensureInitialized().encodeMap<ReleaseAsset>(
      this as ReleaseAsset,
    );
  }

  ReleaseAssetCopyWith<ReleaseAsset, ReleaseAsset, ReleaseAsset> get copyWith =>
      _ReleaseAssetCopyWithImpl<ReleaseAsset, ReleaseAsset>(
        this as ReleaseAsset,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return ReleaseAssetMapper.ensureInitialized().stringifyValue(
      this as ReleaseAsset,
    );
  }

  @override
  bool operator ==(Object other) {
    return ReleaseAssetMapper.ensureInitialized().equalsValue(
      this as ReleaseAsset,
      other,
    );
  }

  @override
  int get hashCode {
    return ReleaseAssetMapper.ensureInitialized().hashValue(
      this as ReleaseAsset,
    );
  }
}

extension ReleaseAssetValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ReleaseAsset, $Out> {
  ReleaseAssetCopyWith<$R, ReleaseAsset, $Out> get $asReleaseAsset =>
      $base.as((v, t, t2) => _ReleaseAssetCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ReleaseAssetCopyWith<$R, $In extends ReleaseAsset, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    int? id,
    String? name,
    int? size,
    String? browserDownloadUrl,
    String? digest,
    int? downloadCount,
  });
  ReleaseAssetCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _ReleaseAssetCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ReleaseAsset, $Out>
    implements ReleaseAssetCopyWith<$R, ReleaseAsset, $Out> {
  _ReleaseAssetCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ReleaseAsset> $mapper =
      ReleaseAssetMapper.ensureInitialized();
  @override
  $R call({
    int? id,
    String? name,
    int? size,
    String? browserDownloadUrl,
    Object? digest = $none,
    int? downloadCount,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (name != null) #name: name,
      if (size != null) #size: size,
      if (browserDownloadUrl != null) #browserDownloadUrl: browserDownloadUrl,
      if (digest != $none) #digest: digest,
      if (downloadCount != null) #downloadCount: downloadCount,
    }),
  );
  @override
  ReleaseAsset $make(CopyWithData data) => ReleaseAsset(
    id: data.get(#id, or: $value.id),
    name: data.get(#name, or: $value.name),
    size: data.get(#size, or: $value.size),
    browserDownloadUrl: data.get(
      #browserDownloadUrl,
      or: $value.browserDownloadUrl,
    ),
    digest: data.get(#digest, or: $value.digest),
    downloadCount: data.get(#downloadCount, or: $value.downloadCount),
  );

  @override
  ReleaseAssetCopyWith<$R2, ReleaseAsset, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ReleaseAssetCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

