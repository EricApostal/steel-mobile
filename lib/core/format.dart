String formatBytes(int bytes) {
  const mb = 1024 * 1024;
  if (bytes < 1024) return '$bytes B';
  if (bytes < mb) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  if (bytes >= 1024 * mb) return '${(bytes / (1024 * mb)).toStringAsFixed(1)} GB';
  return '${(bytes / mb).toStringAsFixed(1)} MB';
}

String formatDate(DateTime date) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec', //
  ];
  final d = date.toLocal();
  return '${months[d.month - 1]} ${d.day}, ${d.year}';
}
