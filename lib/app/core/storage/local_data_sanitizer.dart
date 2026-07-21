abstract final class LocalDataSanitizer {
  static Map<String, dynamic> userDisplayHint(Map<String, dynamic> value) => {
        'id': value['id'],
        'firstName': value['firstName'],
        'middleName': value['middleName'],
        'lastName': value['lastName'],
        'emailId': value['emailId'],
        'mobileNumber': value['mobileNumber'],
        'profileImage': value['profileImage'],
        'role': value['role'],
      };

  static Map<String, dynamic> mediaHouseDisplayHint(
          Map<String, dynamic> value) =>
      {
        'id': value['id'],
        'mediaHouseName': value['mediaHouseName'],
        'profileImage': value['profileImage'],
        'logo': value['logo'],
        'discription': value['discription'],
      };
}
