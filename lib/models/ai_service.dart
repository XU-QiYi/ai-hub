class AiService {
  final String name;
  final String url;
  final String description;
  final String iconPath;
  final String? packageName;

  const AiService({
    required this.name,
    required this.url,
    required this.description,
    required this.iconPath,
    this.packageName,
  });
}
