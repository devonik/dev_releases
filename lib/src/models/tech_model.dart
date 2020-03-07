class Tech {
  final int id;
  final String title;
  final String heroImage;
  final String latestTag;
  final String githubOwner;
  final String githubRepo;
  final String createdAt;
  final String updatedAt;

  Tech({this.id, this.title, this.heroImage, this.latestTag, this.githubOwner,
      this.githubRepo, this.createdAt, this.updatedAt});

  factory Tech.fromJson(Map<String, dynamic> json) {
    return Tech(
      id: json['id'],
      title: json['title'],
      heroImage: json['hero_image'],
      latestTag: json['latest_tag'],
      githubOwner: json['github_owner'],
      githubRepo: json['github_repo'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at']
    );
  }
}
