import '../../../domain/entities/mediaHouse.dart';

class AddMediaHouseResponse {
  MediaHouse? mediaHouse;

  AddMediaHouseResponse({this.mediaHouse});

  AddMediaHouseResponse.fromJson(Map<String, dynamic> json) {
    mediaHouse = json['mediaHouse'] != null
        ? new MediaHouse.fromJson(json['mediaHouse'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.mediaHouse != null) {
      data['mediaHouse'] = this.mediaHouse!.toJson();
    }
    return data;
  }
}




