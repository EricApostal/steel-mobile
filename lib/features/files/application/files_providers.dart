import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../instances/application/instances_controller.dart';
import '../data/file_service.dart';

part 'files_providers.g.dart';

@riverpod
FileService fileService(Ref ref, String instanceId) =>
    FileService(ref.watch(instanceStoreProvider).dirFor(instanceId));

/// Contents of one directory ([path] is relative to the instance root).
@riverpod
Future<List<FileEntry>> directoryListing(Ref ref, String instanceId, String path) =>
    ref.watch(fileServiceProvider(instanceId)).list(path);

/// The instance's root directory, for display purposes.
@riverpod
Directory instanceRoot(Ref ref, String instanceId) =>
    ref.watch(instanceStoreProvider).dirFor(instanceId);
