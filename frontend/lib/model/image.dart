class ImageItem {
  final int id;
  final String name;

  ImageItem({required this.id, required this.name});

  factory ImageItem.fromJson(Map<String, dynamic> json) {
    return ImageItem(
        id: json["id"],
        name: json["name"]
    );
  }
}