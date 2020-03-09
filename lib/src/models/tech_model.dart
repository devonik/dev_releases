class Tech {
  final int id;
  final int githubReleaseId;
  final String githubLink;
  final String releasePublishedAt;
  final String body;
  final String title;
  final String heroImage;
  final String latestTag;
  final String githubOwner;
  final String githubRepo;
  final String createdAt;
  final String updatedAt;

  Tech({this.id, this.githubReleaseId, this.githubLink, this.releasePublishedAt, this.body, this.title, this.heroImage, this.latestTag, this.githubOwner,
      this.githubRepo, this.createdAt, this.updatedAt});

  factory Tech.fromJson(Map<String, dynamic> json) {
    return Tech(
      id: json['id'],
      githubReleaseId: json['github_release_id'],
      githubLink: json['github_link'],
      releasePublishedAt: json['release_published_at'],
      body: json['body'],
      title: json['title'],
      heroImage: json['hero_image'],
      latestTag: json['latest_tag'],
      githubOwner: json['github_owner'],
      githubRepo: json['github_repo'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at']
    );
  }

  factory Tech.fromMap(Map<String, dynamic> map) => new Tech(
        id: map['id'],
        githubReleaseId: map['githubReleaseId'],
        githubLink: map['githubLink'],
        releasePublishedAt: map['releasePublishedAt'],
        body: map['body'],
        title: map['title'],
        heroImage: map['heroImage'],
        latestTag: map['latestTag'],
        githubOwner: map['githubOwner'],
        githubRepo: map['githubRepo'],
        createdAt: map['createdAt'],
        updatedAt: map['updatedAt']
  );

  // Convert a Dog into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'githubReleaseId': githubReleaseId,
      'githubLink': githubLink,
      'releasePublishedAt': releasePublishedAt,
      'body': body,
      'title': title,
      'heroImage': heroImage,
      'latestTag': latestTag,
      'githubOwner': githubOwner,
      'githubRepo': githubRepo,
      'createdAt': createdAt,
      'updatedAt': updatedAt
    };
  }

}
