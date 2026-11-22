import 'dart:convert';
import 'dart:io';

/// One row in the file browser.
class FileEntry {
  const FileEntry({
    required this.name,
    required this.path,
    required this.isDirectory,
    required this.size,
    required this.modified,
  });

  final String name;
  final String path;
  final bool isDirectory;
  final int size;
  final DateTime modified;

  String get extension {
    final dot = name.lastIndexOf('.');
    return dot <= 0 ? '' : name.substring(dot + 1).toLowerCase();
  }
}

sealed class FilePreview {
  const FilePreview();
}

class TextPreview extends FilePreview {
  const TextPreview(this.text);
  final String text;
}

class ImagePreview extends FilePreview {
  const ImagePreview(this.file);
  final File file;
}

class UnsupportedPreview extends FilePreview {
  const UnsupportedPreview(this.reason);
  final String reason;
}

/// File operations confined to one instance's directory.
class FileService {
  const FileService(this.root);

  final Directory root;

  static const maxEditableBytes = 512 * 1024;
  static const _imageExtensions = {'png', 'jpg', 'jpeg', 'gif', 'webp'};

  /// Resolves a `/`-separated path relative to [root], refusing anything that
  /// would escape it.
  String resolve(String relative) {
    final parts = relative.split('/').where((p) => p.isNotEmpty);
    if (parts.any((p) => p == '..' || p == '.')) {
      throw ArgumentError('Invalid path: $relative');
    }
    return [root.path, ...parts].join('/');
  }

  /// Folders first, then files, each alphabetical.
  Future<List<FileEntry>> list(String relative) async {
    final dir = Directory(resolve(relative));
    if (!await dir.exists()) return const [];
    final entries = <FileEntry>[];
    await for (final e in dir.list(followLinks: false)) {
      final stat = await e.stat();
      entries.add(FileEntry(
        name: e.uri.pathSegments.lastWhere((s) => s.isNotEmpty),
        path: e.path.substring(root.path.length).replaceFirst(RegExp(r'^/'), ''),
        isDirectory: stat.type == FileSystemEntityType.directory,
        size: stat.size,
        modified: stat.modified,
      ));
    }
    entries.sort((a, b) {
      if (a.isDirectory != b.isDirectory) return a.isDirectory ? -1 : 1;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return entries;
  }

  Future<FilePreview> preview(String relative) async {
    final file = File(resolve(relative));
    final size = await file.length();
    final ext = relative.contains('.') ? relative.split('.').last.toLowerCase() : '';
    if (_imageExtensions.contains(ext)) return ImagePreview(file);
    if (size > maxEditableBytes) {
      return const UnsupportedPreview('This file is too large to open here.');
    }
    final bytes = await file.readAsBytes();
    if (bytes.take(4096).contains(0)) {
      return const UnsupportedPreview('Binary file, no preview available.');
    }
    return TextPreview(const Utf8Decoder(allowMalformed: true).convert(bytes));
  }

  Future<void> writeText(String relative, String text) =>
      File(resolve(relative)).writeAsString(text, flush: true);

  Future<void> createFile(String parent, String name) async =>
      File(resolve('$parent/${_validName(name)}')).create(exclusive: true);

  Future<void> createDirectory(String parent, String name) async =>
      Directory(resolve('$parent/${_validName(name)}')).create();

  Future<void> rename(FileEntry entry, String newName) async {
    final parent = entry.path.contains('/')
        ? entry.path.substring(0, entry.path.lastIndexOf('/'))
        : '';
    final target = resolve('$parent/${_validName(newName)}');
    if (entry.isDirectory) {
      await Directory(resolve(entry.path)).rename(target);
    } else {
      await File(resolve(entry.path)).rename(target);
    }
  }

  Future<void> delete(FileEntry entry) async {
    if (entry.isDirectory) {
      await Directory(resolve(entry.path)).delete(recursive: true);
    } else {
      await File(resolve(entry.path)).delete();
    }
  }

  /// Error text for an invalid file name, or null if it is fine.
  static String? validateName(String name) {
    final n = name.trim();
    if (n.isEmpty) return 'Enter a name';
    if (n == '.' || n == '..' || n.contains('/')) return 'Invalid name';
    return null;
  }

  String _validName(String name) {
    final error = validateName(name);
    if (error != null) throw ArgumentError(error);
    return name.trim();
  }
}
