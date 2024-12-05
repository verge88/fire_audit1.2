class Law {
  final String title;
  final String fileUrl;

  Law({required this.title, required this.fileUrl});

  factory Law.fromJson(Map<String, dynamic> json) {
    return Law(
      title: json['title'],
      fileUrl: json['fileUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'fileUrl': fileUrl,
    };
  }
}
