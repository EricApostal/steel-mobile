// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'files_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(fileService)
final fileServiceProvider = FileServiceFamily._();

final class FileServiceProvider
    extends $FunctionalProvider<FileService, FileService, FileService>
    with $Provider<FileService> {
  FileServiceProvider._({
    required FileServiceFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'fileServiceProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$fileServiceHash();

  @override
  String toString() {
    return r'fileServiceProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<FileService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FileService create(Ref ref) {
    final argument = this.argument as String;
    return fileService(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FileService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FileService>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FileServiceProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$fileServiceHash() => r'89535de14c3b248e6ef9b13bd4235ebf678d194f';

final class FileServiceFamily extends $Family
    with $FunctionalFamilyOverride<FileService, String> {
  FileServiceFamily._()
    : super(
        retry: null,
        name: r'fileServiceProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FileServiceProvider call(String instanceId) =>
      FileServiceProvider._(argument: instanceId, from: this);

  @override
  String toString() => r'fileServiceProvider';
}

/// Contents of one directory ([path] is relative to the instance root).

@ProviderFor(directoryListing)
final directoryListingProvider = DirectoryListingFamily._();

/// Contents of one directory ([path] is relative to the instance root).

final class DirectoryListingProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<FileEntry>>,
          List<FileEntry>,
          FutureOr<List<FileEntry>>
        >
    with $FutureModifier<List<FileEntry>>, $FutureProvider<List<FileEntry>> {
  /// Contents of one directory ([path] is relative to the instance root).
  DirectoryListingProvider._({
    required DirectoryListingFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'directoryListingProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$directoryListingHash();

  @override
  String toString() {
    return r'directoryListingProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<FileEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<FileEntry>> create(Ref ref) {
    final argument = this.argument as (String, String);
    return directoryListing(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is DirectoryListingProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$directoryListingHash() => r'c81152e8e0bb0b89b2568c027a1634d80e7c8c22';

/// Contents of one directory ([path] is relative to the instance root).

final class DirectoryListingFamily extends $Family
    with
        $FunctionalFamilyOverride<FutureOr<List<FileEntry>>, (String, String)> {
  DirectoryListingFamily._()
    : super(
        retry: null,
        name: r'directoryListingProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Contents of one directory ([path] is relative to the instance root).

  DirectoryListingProvider call(String instanceId, String path) =>
      DirectoryListingProvider._(argument: (instanceId, path), from: this);

  @override
  String toString() => r'directoryListingProvider';
}

/// The instance's root directory, for display purposes.

@ProviderFor(instanceRoot)
final instanceRootProvider = InstanceRootFamily._();

/// The instance's root directory, for display purposes.

final class InstanceRootProvider
    extends $FunctionalProvider<Directory, Directory, Directory>
    with $Provider<Directory> {
  /// The instance's root directory, for display purposes.
  InstanceRootProvider._({
    required InstanceRootFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'instanceRootProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$instanceRootHash();

  @override
  String toString() {
    return r'instanceRootProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<Directory> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Directory create(Ref ref) {
    final argument = this.argument as String;
    return instanceRoot(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Directory value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Directory>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is InstanceRootProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$instanceRootHash() => r'e3776ecfad83d3a1fa575c84c53c52b6175159b1';

/// The instance's root directory, for display purposes.

final class InstanceRootFamily extends $Family
    with $FunctionalFamilyOverride<Directory, String> {
  InstanceRootFamily._()
    : super(
        retry: null,
        name: r'instanceRootProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The instance's root directory, for display purposes.

  InstanceRootProvider call(String instanceId) =>
      InstanceRootProvider._(argument: instanceId, from: this);

  @override
  String toString() => r'instanceRootProvider';
}
