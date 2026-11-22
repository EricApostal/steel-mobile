// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'release.dart';

class ReleaseMapper extends ClassMapperBase<Release> {
  ReleaseMapper._();

  static ReleaseMapper? _instance;
  static ReleaseMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ReleaseMapper._());
      ReleaseAssetMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'Release';

  static int _$id(Release v) => v.id;
  static const Field<Release, int> _f$id = Field('id', _$id);
  static String _$tagName(Release v) => v.tagName;
  static const Field<Release, String> _f$tagName = Field(
    'tagName',
    _$tagName,
    key: r'tag_name',
  );
  static String _$htmlUrl(Release v) => v.htmlUrl;
  static const Field<Release, String> _f$htmlUrl = Field(
    'htmlUrl',
    _$htmlUrl,
    key: r'html_url',
  );
  static String? _$name(Release v) => v.name;
  static const Field<Release, String> _f$name = Field(
    'name',
    _$name,
    opt: true,
  );
  static String? _$body(Release v) => v.body;
  static const Field<Release, String> _f$body = Field(
    'body',
    _$body,
    opt: true,
  );
  static bool _$draft(Release v) => v.draft;
  static const Field<Release, bool> _f$draft = Field(
    'draft',
    _$draft,
    opt: true,
    def: false,
  );
  static bool _$prerelease(Release v) => v.prerelease;
  static const Field<Release, bool> _f$prerelease = Field(
    'prerelease',
    _$prerelease,
    opt: true,
    def: false,
  );
  static DateTime? _$publishedAt(Release v) => v.publishedAt;
  static const Field<Release, DateTime> _f$publishedAt = Field(
    'publishedAt',
    _$publishedAt,
    key: r'published_at',
    opt: true,
  );
  static List<ReleaseAsset> _$assets(Release v) => v.assets;
  static const Field<Release, List<ReleaseAsset>> _f$assets = Field(
    'assets',
    _$assets,
    opt: true,
    def: const [],
  );

  @override
  final MappableFields<Release> fields = const {
    #id: _f$id,
    #tagName: _f$tagName,
    #htmlUrl: _f$htmlUrl,
    #name: _f$name,
    #body: _f$body,
    #draft: _f$draft,
    #prerelease: _f$prerelease,
    #publishedAt: _f$publishedAt,
    #assets: _f$assets,
  };

  static Release _instantiate(DecodingData data) {
    return Release(
      id: data.dec(_f$id),
      tagName: data.dec(_f$tagName),
      htmlUrl: data.dec(_f$htmlUrl),
      name: data.dec(_f$name),
      body: data.dec(_f$body),
      draft: data.dec(_f$draft),
      prerelease: data.dec(_f$prerelease),
      publishedAt: data.dec(_f$publishedAt),
      assets: data.dec(_f$assets),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static Release fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Release>(map);
  }

  static Release fromJson(String json) {
    return ensureInitialized().decodeJson<Release>(json);
  }
}

mixin ReleaseMappable {
  String toJson() {
    return ReleaseMapper.ensureInitialized().encodeJson<Release>(
      this as Release,
    );
  }

  Map<String, dynamic> toMap() {
    return ReleaseMapper.ensureInitialized().encodeMap<Release>(
      this as Release,
    );
  }

  ReleaseCopyWith<Release, Release, Release> get copyWith =>
      _ReleaseCopyWithImpl<Release, Release>(
        this as Release,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return ReleaseMapper.ensureInitialized().stringifyValue(this as Release);
  }

  @override
  bool operator ==(Object other) {
    return ReleaseMapper.ensureInitialized().equalsValue(
      this as Release,
      other,
    );
  }

  @override
  int get hashCode {
    return ReleaseMapper.ensureInitialized().hashValue(this as Release);
  }
}

extension ReleaseValueCopy<$R, $Out> on ObjectCopyWith<$R, Release, $Out> {
  ReleaseCopyWith<$R, Release, $Out> get $asRelease =>
      $base.as((v, t, t2) => _ReleaseCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ReleaseCopyWith<$R, $In extends Release, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<
    $R,
    ReleaseAsset,
    ReleaseAssetCopyWith<$R, ReleaseAsset, ReleaseAsset>
  >
  get assets;
  $R call({
    int? id,
    String? tagName,
    String? htmlUrl,
    String? name,
    String? body,
    bool? draft,
    bool? prerelease,
    DateTime? publishedAt,
    List<ReleaseAsset>? assets,
  });
  ReleaseCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _ReleaseCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, Release, $Out>
    implements ReleaseCopyWith<$R, Release, $Out> {
  _ReleaseCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Release> $mapper =
      ReleaseMapper.ensureInitialized();
  @override
  ListCopyWith<
    $R,
    ReleaseAsset,
    ReleaseAssetCopyWith<$R, ReleaseAsset, ReleaseAsset>
  >
  get assets => ListCopyWith(
    $value.assets,
    (v, t) => v.copyWith.$chain(t),
    (v) => call(assets: v),
  );
  @override
  $R call({
    int? id,
    String? tagName,
    String? htmlUrl,
    Object? name = $none,
    Object? body = $none,
    bool? draft,
    bool? prerelease,
    Object? publishedAt = $none,
    List<ReleaseAsset>? assets,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (tagName != null) #tagName: tagName,
      if (htmlUrl != null) #htmlUrl: htmlUrl,
      if (name != $none) #name: name,
      if (body != $none) #body: body,
      if (draft != null) #draft: draft,
      if (prerelease != null) #prerelease: prerelease,
      if (publishedAt != $none) #publishedAt: publishedAt,
      if (assets != null) #assets: assets,
    }),
  );
  @override
  Release $make(CopyWithData data) => Release(
    id: data.get(#id, or: $value.id),
    tagName: data.get(#tagName, or: $value.tagName),
    htmlUrl: data.get(#htmlUrl, or: $value.htmlUrl),
    name: data.get(#name, or: $value.name),
    body: data.get(#body, or: $value.body),
    draft: data.get(#draft, or: $value.draft),
    prerelease: data.get(#prerelease, or: $value.prerelease),
    publishedAt: data.get(#publishedAt, or: $value.publishedAt),
    assets: data.get(#assets, or: $value.assets),
  );

  @override
  ReleaseCopyWith<$R2, Release, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _ReleaseCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

