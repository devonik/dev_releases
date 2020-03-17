import 'package:dev_releases/src/models/tech_model.dart';

class AddTechResponse {
  final dynamic tech;
  final String error;
  final dynamic errorDetail;

  AddTechResponse({this.tech, this.error, this.errorDetail});

  factory AddTechResponse.fromJson(Map<String, dynamic> json) {
    return AddTechResponse(
        tech: json['tech'],
        error: json['error'],
        errorDetail: json['errorDetail'],
    );
  }


}
