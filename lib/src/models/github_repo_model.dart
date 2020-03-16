class GithubRepo {
  final int id;
  final String repoName;
  final String ownerName;
  final String displayName;

  GithubRepo({this.id, this.repoName, this.ownerName, this.displayName});

  factory GithubRepo.fromJson(Map<String, dynamic> json) {
    return GithubRepo(
        id: json['id'],
        repoName: json['name'],
        ownerName: json['owner']['login'],
        displayName: json['full_name']
    );
  }


}
