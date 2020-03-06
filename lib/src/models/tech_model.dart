class Tech {
  final int userId;
  final int id;
  final String title;

  Tech({this.userId, this.id, this.title});

  factory Tech.fromJson(Map<String, dynamic> json) {
    return Tech(
      userId: json['userId'],
      id: json['id'],
      title: json['title'],
    );
  }
}
