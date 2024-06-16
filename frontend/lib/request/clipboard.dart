class PostTextRequest {
  String text;

  PostTextRequest({required this.text});

  Map<String, dynamic> toJson() {
    return {
      "text": text
    };
  }
}