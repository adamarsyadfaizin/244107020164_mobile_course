String formatLastOpened(String? isoTimestamp) {
  if (isoTimestamp == null || isoTimestamp.isEmpty) {
    return 'Belum pernah dibuka';
  }
  return isoTimestamp;
}

int parseNoteId(String? pathValue) => int.tryParse(pathValue ?? '') ?? 0;
