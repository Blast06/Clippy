class ClipboardFolder {
  const ClipboardFolder({
    required this.id,
    required this.name,
    this.description,
  });

  final String id;
  final String name;
  final String? description;
}
