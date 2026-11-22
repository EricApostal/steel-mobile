// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'browser_path.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The folder the file browser is showing (segments below the instance root),
/// kept while you switch tabs.

@ProviderFor(BrowserPath)
final browserPathProvider = BrowserPathFamily._();

/// The folder the file browser is showing (segments below the instance root),
/// kept while you switch tabs.
final class BrowserPathProvider
    extends $NotifierProvider<BrowserPath, List<String>> {
  /// The folder the file browser is showing (segments below the instance root),
  /// kept while you switch tabs.
  BrowserPathProvider._({
    required BrowserPathFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'browserPathProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$browserPathHash();

  @override
  String toString() {
    return r'browserPathProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  BrowserPath create() => BrowserPath();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<String>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is BrowserPathProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$browserPathHash() => r'7c7b846431a8f6e8584b6bd71cd329ede22a646b';

/// The folder the file browser is showing (segments below the instance root),
/// kept while you switch tabs.

final class BrowserPathFamily extends $Family
    with
        $ClassFamilyOverride<
          BrowserPath,
          List<String>,
          List<String>,
          List<String>,
          String
        > {
  BrowserPathFamily._()
    : super(
        retry: null,
        name: r'browserPathProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// The folder the file browser is showing (segments below the instance root),
  /// kept while you switch tabs.

  BrowserPathProvider call(String instanceId) =>
      BrowserPathProvider._(argument: instanceId, from: this);

  @override
  String toString() => r'browserPathProvider';
}

/// The folder the file browser is showing (segments below the instance root),
/// kept while you switch tabs.

abstract class _$BrowserPath extends $Notifier<List<String>> {
  late final _$args = ref.$arg as String;
  String get instanceId => _$args;

  List<String> build(String instanceId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<List<String>, List<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<String>, List<String>>,
              List<String>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
