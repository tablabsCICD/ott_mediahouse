import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:media_house/data/models/response/getMediaHouseResponse.dart';
import 'package:media_house/data/models/response/image_upload_response.dart';
import 'package:media_house/data/models/response/mediaHouseDashboardCount.dart';

import '../../data/models/response/chartResponse.dart';
import '../../domain/entities/mediaHouse.dart';
import '../core/constant/api_constant.dart';
import '../core/network/api_helper.dart';
import '../core/utils/sharepreferences.dart';
import '../widget/show_toast.dart';
import 'dart:io' as io;
import 'package:http/http.dart' as http;
import 'package:universal_html/html.dart' as html;

import 'package:image_picker/image_picker.dart'; // For web-specific file handling

class MediaHouseProvider extends ChangeNotifier {
  MediaHouseProvider() : super() {}

  TextEditingController searchMediaHouseController = TextEditingController();
  TextEditingController mediaHouseNameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController adharCardController = TextEditingController();
  TextEditingController panCardController = TextEditingController();
  TextEditingController shopActController = TextEditingController();
  TextEditingController gstController = TextEditingController();
  TextEditingController bankProofController = TextEditingController();
  TextEditingController identityProofController = TextEditingController();
  TextEditingController addressProofController = TextEditingController();
  TextEditingController registrationCertificateController =
      TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController officeBuildingController = TextEditingController();
  TextEditingController registrationDateController = TextEditingController();
  TextEditingController profileController = TextEditingController();
  TextEditingController otpController = TextEditingController();
  TextEditingController refferedByController = TextEditingController();
  TextEditingController roleController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController districtController = TextEditingController();
  TextEditingController talukaController = TextEditingController();
  bool isEnbale = false;

  MediaHouse _mediaHouse = MediaHouse();
  MediaHouse get mediaHouse => _mediaHouse;
  File? pickedProfileImage; // 👈 add this
  String? selectedImage;

  MediaHouseDashboardData _mediaHouseDashboardData = MediaHouseDashboardData();
  MediaHouseDashboardData get mediaHouseDashboardData =>
      _mediaHouseDashboardData;

  // Fetch all moviesByMediaHouseId
  Future<void> fetchMediaHouseDashboardData(int mediaHouseId) async {
    String apiUrl = ApiConstant.getMediaHouseDashboardCount(mediaHouseId);
    ApiHelper apiHelper = ApiHelper();
    try {
      var response = await apiHelper.getApi(apiUrl);
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        debugPrint("response::: " + responseBody.toString());
        MediaHouseDashboardCount mediaHouseDashboardCount =
            MediaHouseDashboardCount.fromJson(responseBody);
        debugPrint("data::: " + mediaHouseDashboardCount.data.toString());
        if (mediaHouseDashboardCount.isSuccess == true) {
          if (mediaHouseDashboardCount.data != null) {
            _mediaHouseDashboardData = mediaHouseDashboardCount.data!;
            debugPrint("message : ${mediaHouseDashboardCount.message}");
            notifyListeners();
          } else {
            debugPrint("empty list: ${mediaHouseDashboardCount.message}");
          }
        } else {
          debugPrint("Error: ${mediaHouseDashboardCount.message}");
        }
      } else {
        throw Exception(
            'Failed to fetch Content. Status code: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint("Error: $error");
      throw Exception('An error occurred while fetching Content.');
    }
  }

  io.File? _imageFile; // For mobile platforms
  html.File? _webFile; // For web platform
  String? _uploadedImageUrl;
  bool _isUploading = false;

  // Getters
  io.File? get imageFile => _imageFile;
  html.File? get webFile => _webFile;
  String? get uploadedImageUrl => _uploadedImageUrl;
  bool get isUploading => _isUploading;

  // Pick Image
  Future<void> pickImage(String label) async {
    if (kIsWeb) {
      // Web file picker
      final html.FileUploadInputElement uploadInput =
          html.FileUploadInputElement();
      uploadInput.accept = 'image/*';
      uploadInput.click();

      uploadInput.onChange.listen((event) async {
        if (uploadInput.files != null && uploadInput.files!.isNotEmpty) {
          _webFile = uploadInput.files!.first;
          await uploadImage(label);
          notifyListeners();
        }
      });
    } else {
      // Mobile/desktop file picker
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        _imageFile = io.File(pickedFile.path);
        if (kIsWeb && _webFile != null) {
          await uploadImage(label);
        }
        notifyListeners();
      }
    }
  }

  ImageProvider? get profileImageProvider {
    if (!kIsWeb && _imageFile != null) {
      return FileImage(_imageFile!);
    }

    if (kIsWeb && selectedImage != null) {
      return NetworkImage(selectedImage!);
    }

    if (profileController.text.isNotEmpty) {
      return NetworkImage(
        "${profileController.text}?v=${DateTime.now().millisecondsSinceEpoch}",
      );
    }

    if (_mediaHouse.logo != null && _mediaHouse.logo!.isNotEmpty) {
      return NetworkImage(
        "${_mediaHouse.logo}?v=${DateTime.now().millisecondsSinceEpoch}",
      );
    }

    return null;
  }

  // Upload Image
  Future<void> uploadImage(String lable) async {
    if ((!kIsWeb && _imageFile == null) || (kIsWeb && _webFile == null)) {
      return; // No file selected
    }

    final url = Uri.parse(ApiConstant.uploadImg);
    _isUploading = true;
    notifyListeners();

    try {
      if (kIsWeb && _webFile != null) {
        // Web upload logic
        final request = http.MultipartRequest('POST', url);
        final reader = html.FileReader();
        reader.readAsArrayBuffer(_webFile!);
        await reader.onLoad.first;

        final byteData = reader.result as List<int>;
        final multipartFile = http.MultipartFile.fromBytes(
          'file',
          byteData,
          filename: _webFile!.name,
        );

        request.files.add(multipartFile);
        final response = await request.send();
        debugPrint("Image upload response======${response.statusCode}");
        if (response.statusCode == 200) {
          final responseBody = await response.stream.bytesToString();
          ImageUploadResponse imageUploadResponse =
              ImageUploadResponse.fromJson(jsonDecode(responseBody));
          _uploadedImageUrl = imageUploadResponse.data!.fileUrl;
          print(lable + " = $_uploadedImageUrl");
          if ("Aadhaar Card" == lable) {
            adharCardController.text = _uploadedImageUrl!;
            print(lable + adharCardController.text);
            uploadedDocuments['Aadhaar Card'] = {
              'file': adharCardController.text,
              'description':
                  'Government-issued identity proof for Indian citizens.',
              'fileName': '',
              'fileSize': ''
            };
          } else if ("Pan Card" == lable) {
            panCardController.text = _uploadedImageUrl!;
            print(lable + panCardController.text);
            uploadedDocuments['Pan Card'] = {
              'file': panCardController.text,
              'description':
                  'Permanent Account Number (PAN) card for tax identification.',
              'fileName': '',
              'fileSize': ''
            };
          } else if ("Shop Act" == lable) {
            shopActController.text = _uploadedImageUrl!;
            print(lable + shopActController.text);
            uploadedDocuments['Shop Act'] = {
              'file': shopActController.text,
              'description':
                  'Legal license for business under the Shops & Establishments Act.',
              'fileName': '',
              'fileSize': ''
            };
          } else if ("GST Certificate" == lable) {
            gstController.text = _uploadedImageUrl!;
            print(lable + gstController.text);
            uploadedDocuments['GST Certificate'] = {
              'file': gstController.text,
              'description':
                  'Government-issued certificate confirming business registration.',
              'fileName': '',
              'fileSize': ''
            };
          } else if ("Registration Certificate" == lable) {
            registrationCertificateController.text = _uploadedImageUrl!;
            print(lable + registrationCertificateController.text);
            uploadedDocuments['Registration Certificate'] = {
              'file': registrationCertificateController.text,
              'description':
                  'Proof of business entity (LLC, Pvt Ltd, Corporation).',
              'fileName': '',
              'fileSize': ''
            };
          } else if ("Bank Proof" == lable) {
            bankProofController.text = _uploadedImageUrl!;
            uploadedDocuments['Bank Proof'] = {
              'file': bankProofController.text,
              'description': 'Cancelled cheque or bank account proof document.',
              'fileName': '',
              'fileSize': ''
            };
          } else if ("Identity Proof" == lable) {
            identityProofController.text = _uploadedImageUrl!;
            uploadedDocuments['Identity Proof'] = {
              'file': identityProofController.text,
              'description': 'Additional government-issued identity proof.',
              'fileName': '',
              'fileSize': ''
            };
          } else if ("Address Proof" == lable) {
            addressProofController.text = _uploadedImageUrl!;
            uploadedDocuments['Address Proof'] = {
              'file': addressProofController.text,
              'description': 'Proof of registered office address.',
              'fileName': '',
              'fileSize': ''
            };
          } else {
            selectedImage = _uploadedImageUrl;
            profileController.text = _uploadedImageUrl!;
            print(lable + selectedImage.toString());
          }
          await updateMediaHouseDocument();
          notifyListeners();
        }
      } else if (!kIsWeb && _imageFile != null) {
        // Mobile/desktop upload logic
        final request = http.MultipartRequest('POST', url);
        request.files.add(await http.MultipartFile.fromPath(
          'file',
          _imageFile!.path,
          //  contentType: MediaType('image', 'jpeg'),
        ));
        final response = await request.send();

        if (response.statusCode == 200) {
          final responseBody = await response.stream.bytesToString();
          ImageUploadResponse imageUploadResponse =
              ImageUploadResponse.fromJson(jsonDecode(responseBody));
          _uploadedImageUrl = imageUploadResponse.data!.fileUrl;
          print(lable);
          if ("Aadhaar Card" == lable) {
            adharCardController.text = _uploadedImageUrl!;
            print(lable + adharCardController.text);
            uploadedDocuments['Aadhaar Card'] = {
              'file': adharCardController.text,
              'description':
                  'Government-issued identity proof for Indian citizens.',
              'fileName': '',
              'fileSize': ''
            };
          } else if ("Pan Card" == lable) {
            panCardController.text = _uploadedImageUrl!;
            print(lable + panCardController.text);
            uploadedDocuments['Pan Card'] = {
              'file': panCardController.text,
              'description':
                  'Permanent Account Number (PAN) card for tax identification.',
              'fileName': '',
              'fileSize': ''
            };
          } else if ("Shop Act" == lable) {
            shopActController.text = _uploadedImageUrl!;
            print(lable + shopActController.text);
            uploadedDocuments['Shop Act'] = {
              'file': shopActController.text,
              'description':
                  'Legal license for business under the Shops & Establishments Act.',
              'fileName': '',
              'fileSize': ''
            };
          } else if ("GST Certificate" == lable) {
            gstController.text = _uploadedImageUrl!;
            print(lable + gstController.text);
            uploadedDocuments['GST Certificate'] = {
              'file': gstController.text,
              'description':
                  'Government-issued certificate confirming business registration.',
              'fileName': '',
              'fileSize': ''
            };
          } else if ("Registration Certificate" == lable) {
            registrationCertificateController.text = _uploadedImageUrl!;
            print(lable + registrationCertificateController.text);
            uploadedDocuments['Registration Certificate'] = {
              'file': registrationCertificateController.text,
              'description':
                  'Proof of business entity (LLC, Pvt Ltd, Corporation).',
              'fileName': '',
              'fileSize': ''
            };
          } else if ("Bank Proof" == lable) {
            bankProofController.text = _uploadedImageUrl!;
            uploadedDocuments['Bank Proof'] = {
              'file': bankProofController.text,
              'description': 'Cancelled cheque or bank account proof document.',
              'fileName': '',
              'fileSize': ''
            };
          } else if ("Identity Proof" == lable) {
            identityProofController.text = _uploadedImageUrl!;
            uploadedDocuments['Identity Proof'] = {
              'file': identityProofController.text,
              'description': 'Additional government-issued identity proof.',
              'fileName': '',
              'fileSize': ''
            };
          } else if ("Address Proof" == lable) {
            addressProofController.text = _uploadedImageUrl!;
            uploadedDocuments['Address Proof'] = {
              'file': addressProofController.text,
              'description': 'Proof of registered office address.',
              'fileName': '',
              'fileSize': ''
            };
          } else {
            selectedImage = _uploadedImageUrl;
            profileController.text = _uploadedImageUrl!;
            print(lable + selectedImage.toString());
          }
          await updateMediaHouseDocument();
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error uploading image: $e');
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  Map<String, Map<String, dynamic>> uploadedDocuments = {};

  Future<void> fetchMediaHouseByUserId(int userId) async {
    String apiUrl = ApiConstant.getMediaHouseByUserId(userId);
    ApiHelper apiHelper = ApiHelper();

    try {
      var response = await apiHelper.getApi(apiUrl);
      debugPrint("Production house by id response::: ${response.body}");

      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        GetMediaHouse getAllMediaHouseResponse =
            GetMediaHouse.fromJson(responseBody);

        if (getAllMediaHouseResponse.data!.mediaHouse != null) {
          _mediaHouse = getAllMediaHouseResponse.data!.mediaHouse!;

          // Clear previous data to prevent stale documents
          uploadedDocuments.clear();

          // Add documents only if they are not null
          uploadedDocuments['Registration Certificate'] = {
            'file': _mediaHouse.registrationCertificate == ""
                ? null
                : _mediaHouse.registrationCertificate,
            'description':
                'Proof of business entity (LLC, Pvt Ltd, Corporation).',
            'fileName': '',
            'fileSize': ''
          };

          uploadedDocuments['Aadhaar Card'] = {
            'file': _mediaHouse.adharCard == "" ? null : _mediaHouse.adharCard,
            'description':
                'Government-issued identity proof for Indian citizens.',
            'fileName': '',
            'fileSize': ''
          };

          uploadedDocuments['Pan Card'] = {
            'file': _mediaHouse.panCard == "" ? null : _mediaHouse.panCard,
            'description':
                'Permanent Account Number (PAN) card for tax identification.',
            'fileName': '',
            'fileSize': ''
          };

          uploadedDocuments['GST Certificate'] = {
            'file': _mediaHouse.gstCertificates == ""
                ? null
                : _mediaHouse.gstCertificates,
            'description':
                'Government-issued certificate confirming business registration.',
            'fileName': '',
            'fileSize': ''
          };

          uploadedDocuments['Shop Act'] = {
            'file': _mediaHouse.shopAct == "" ? null : _mediaHouse.shopAct,
            'description':
                'Legal license for business under the Shops & Establishments Act.',
            'fileName': '',
            'fileSize': ''
          };

          uploadedDocuments['Bank Proof'] = {
            'file': _mediaHouse.bankProof == "" ? null : _mediaHouse.bankProof,
            'description': 'Cancelled cheque or bank account proof document.',
            'fileName': '',
            'fileSize': ''
          };

          uploadedDocuments['Identity Proof'] = {
            'file': _mediaHouse.identityProof == ""
                ? null
                : _mediaHouse.identityProof,
            'description': 'Additional government-issued identity proof.',
            'fileName': '',
            'fileSize': ''
          };

          uploadedDocuments['Address Proof'] = {
            'file': _mediaHouse.addressProof == ""
                ? null
                : _mediaHouse.addressProof,
            'description': 'Proof of registered office address.',
            'fileName': '',
            'fileSize': ''
          };
          setValue(_mediaHouse);
          notifyListeners();
        } else {
          debugPrint("No data found: ${getAllMediaHouseResponse.message}");
        }
      } else {
        throw Exception(
            'Failed to fetch Production House. Status code: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint("Error: $error");
      throw Exception('An error occurred while fetching Production House.');
    }
  }

  deleteMediaHouse(int id, context) async {
    String apiUrl = ApiConstant.deleteMediaHouseById(id);
    ApiHelper apiHelper = ApiHelper();
    try {
      var response = await apiHelper.deleteApi(apiUrl);
      if (response.statusCode == 200 || response.statusCode == 500) {
        CustomToast.show("Deleted Successfully", isSuccess: true);
        notifyListeners();
        Navigator.pop(context);
      } else {
        throw Exception(
            'Failed to fetch mediaHouse. Status code: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint("Error: $error");
      throw Exception('An error occurred while fetching mediaHouse.');
    }
  }

  // Update user data
  Future<Map<String, Object>> updateMediaHouse() async {
    String apiUrl = ApiConstant.editMediaHouseById;
    ApiHelper apiHelper = ApiHelper();
    Map<String, dynamic> data = {
      "email": emailController.text,
      "mediaHouseName": mediaHouseNameController.text,
      "id": mediaHouse!.id,
      "discription": descriptionController.text,
      "logo": profileController.text.isEmpty
          ? mediaHouse.logo
          : profileController.text,
      "contactNumber": mobileController.text
    };

    try {
      var response = await apiHelper.putApiWithBody(apiUrl, data);
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        GetMediaHouse updateMediaHouseResponse =
            GetMediaHouse.fromJson(responseBody);

        debugPrint("data: ${updateMediaHouseResponse.message}");
        if (updateMediaHouseResponse.success == true) {
          if (updateMediaHouseResponse.data != null) {
            _mediaHouse = updateMediaHouseResponse.data!.mediaHouse!;
            notifyListeners();
            return {
              'success': true,
              'message': updateMediaHouseResponse.message ?? ""
            };
          } else {
            debugPrint("Empty data: ${updateMediaHouseResponse.message}");
            return {
              'success': false,
              'message': updateMediaHouseResponse.message ?? 'No data returned'
            };
          }
        } else {
          debugPrint("Error: ${updateMediaHouseResponse.message}");
          return {
            'success': false,
            'message': updateMediaHouseResponse.message ?? 'Error in response'
          };
        }
      } else if (response.statusCode == 401 || response.statusCode == 404) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        GetMediaHouse addUserResponse = GetMediaHouse.fromJson(responseBody);
        debugPrint("Error: ${addUserResponse.message}");
        return {
          'success': false,
          'message': addUserResponse.message ?? 'Error in response'
        };
      } else {
        return {
          'failure': true,
          'message': 'Something went wrong! ${response.statusCode}'
        };
        // throw Exception('Failed to add user. Status code: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint("Error: $error");
      return {
        'success': false,
        'message': 'An error occurred while update user: $error'
      };
    }
  }

  // Update user data
  Future<Map<String, Object>> updateMediaHouseDocument() async {
    String apiUrl = ApiConstant.editMediaHouseById;
    ApiHelper apiHelper = ApiHelper();
    Map<String, dynamic> data = {
      "registrationCertificate": registrationCertificateController.text,
      "shopAct": shopActController.text,
      "id": mediaHouse.id,
      "contactNumber": mediaHouse.contactNumber,
      "email": mediaHouse.email,
      "adharCard": adharCardController.text,
      "gstCertificates": gstController.text,
      "panCard": panCardController.text,
      "bankProof": bankProofController.text,
      "identityProof": identityProofController.text,
      "addressProof": addressProofController.text,
    };

    debugPrint(data.toString());

    try {
      var response = await apiHelper.putApiWithBody(apiUrl, data);
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        GetMediaHouse updateMediaHouseResponse =
            GetMediaHouse.fromJson(responseBody);

        debugPrint("data: ${updateMediaHouseResponse.message}");
        if (updateMediaHouseResponse.success == true) {
          if (updateMediaHouseResponse.data != null) {
            _mediaHouse = updateMediaHouseResponse.data!.mediaHouse!;
            notifyListeners();
            return {
              'success': true,
              'message': updateMediaHouseResponse.message ?? ""
            };
          } else {
            debugPrint("Empty data: ${updateMediaHouseResponse.message}");
            return {
              'success': false,
              'message': updateMediaHouseResponse.message ?? 'No data returned'
            };
          }
        } else {
          debugPrint("Error: ${updateMediaHouseResponse.message}");
          return {
            'success': false,
            'message': updateMediaHouseResponse.message ?? 'Error in response'
          };
        }
      } else if (response.statusCode == 401 || response.statusCode == 404) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        GetMediaHouse addUserResponse = GetMediaHouse.fromJson(responseBody);
        debugPrint("Error: ${addUserResponse.message}");
        return {
          'success': false,
          'message': addUserResponse.message ?? 'Error in response'
        };
      } else {
        return {
          'failure': true,
          'message': 'Something went wrong! ${response.statusCode}'
        };
        // throw Exception('Failed to add user. Status code: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint("Error: $error");
      return {
        'success': false,
        'message': 'An error occurred while update user: $error'
      };
    }
  }

  void setValue(MediaHouse mediaHouse) {
    print("SEtData${mediaHouse!.mediaHouseName}");
    mediaHouseNameController.text = mediaHouse.mediaHouseName ?? "";
    mobileController.text = mediaHouse.contactNumber ?? "";
    emailController.text = mediaHouse.email ?? "";
    descriptionController.text = mediaHouse.discription ?? "";
    profileController.text = mediaHouse.logo ?? "";
    adharCardController.text = mediaHouse.adharCard ?? "";
    panCardController.text = mediaHouse.panCard ?? "";
    shopActController.text = mediaHouse.shopAct ?? "";
    gstController.text = mediaHouse.gstCertificates ?? "";
    bankProofController.text = mediaHouse.bankProof ?? "";
    identityProofController.text = mediaHouse.identityProof ?? "";
    addressProofController.text = mediaHouse.addressProof ?? "";
    registrationCertificateController.text =
        mediaHouse.registrationCertificate ?? "";
    notifyListeners();
  }

  clearController(title) {
    print(title);
    if (title == "Shop Act") {
      print("clear controller");
      shopActController.clear();
    } else if (title == "GST Certificate") {
      gstController.clear();
    } else if (title == "Pan Card") {
      panCardController.clear();
    } else if (title == "Aadhaar Card") {
      adharCardController.clear();
    } else if (title == "Bank Proof") {
      bankProofController.clear();
    } else if (title == "Identity Proof") {
      identityProofController.clear();
    } else if (title == "Address Proof") {
      addressProofController.clear();
    } else {
      registrationCertificateController.clear();
    }
    notifyListeners();
  }

  bool isYear = false;
  bool isMonth = true;
  bool isWeek = false;
  List<LineChartData> graphData = [];

  String _customGraphContentType = "ALL";
  String _customGraphCountry = "";
  String _customGraphState = "";
  String _customGraphDistrict = "";
  String _customGraphTaluka = "";
  String _customGraphCity = "";

  String get customGraphContentType => _customGraphContentType;
  String get customGraphCountry => _customGraphCountry;
  String get customGraphState => _customGraphState;
  String get customGraphDistrict => _customGraphDistrict;
  String get customGraphTaluka => _customGraphTaluka;
  String get customGraphCity => _customGraphCity;

  final List<String> _customGraphCountryOptions = [];
  List<String> get customGraphCountryOptions => _customGraphCountryOptions;

  final List<String> _customGraphStateOptions = [];
  List<String> get customGraphStateOptions => _customGraphStateOptions;

  bool _isLoadingCustomGraphCountries = false;
  bool get isLoadingCustomGraphCountries => _isLoadingCustomGraphCountries;

  bool _isLoadingCustomGraphStates = false;
  bool get isLoadingCustomGraphStates => _isLoadingCustomGraphStates;

  String? _normalizeFilter(String value, {bool allAsNull = false}) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    if (allAsNull && trimmed.toUpperCase() == "ALL") return null;
    return trimmed;
  }

  void setCustomGraphContentType(String value) {
    _customGraphContentType = value;
    notifyListeners();
  }

  void setCustomGraphCountry(String value) {
    _customGraphCountry = value;
    notifyListeners();
  }

  void setCustomGraphState(String value) {
    _customGraphState = value;
    notifyListeners();
  }

  void setCustomGraphDistrict(String value) {
    _customGraphDistrict = value;
    notifyListeners();
  }

  void setCustomGraphTaluka(String value) {
    _customGraphTaluka = value;
    notifyListeners();
  }

  void setCustomGraphCity(String value) {
    _customGraphCity = value;
    notifyListeners();
  }

  void clearCustomGraphFilters() {
    _customGraphContentType = "ALL";
    _customGraphCountry = "";
    _customGraphState = "";
    _customGraphDistrict = "";
    _customGraphTaluka = "";
    _customGraphCity = "";
    _customGraphStateOptions.clear();
    notifyListeners();
  }

  Future<void> fetchCustomGraphCountriesIfNeeded() async {
    if (_customGraphCountryOptions.isNotEmpty ||
        _isLoadingCustomGraphCountries) {
      return;
    }
    await fetchCustomGraphCountries();
  }

  Future<void> fetchCustomGraphCountries() async {
    _isLoadingCustomGraphCountries = true;
    notifyListeners();
    try {
      final response = await http.get(
        Uri.parse('https://countriesnow.space/api/v0.1/countries/positions'),
      );
      if (response.statusCode != 200) return;
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final data = (body['data'] as List<dynamic>? ?? const []);
      _customGraphCountryOptions
        ..clear()
        ..addAll(
          data
              .map((item) =>
                  (item as Map<String, dynamic>)['name']?.toString() ?? '')
              .where((name) => name.trim().isNotEmpty),
        );
      _customGraphCountryOptions
          .sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    } catch (_) {
      // Leave list empty on failure; manual location text filters still work.
    } finally {
      _isLoadingCustomGraphCountries = false;
      notifyListeners();
    }
  }

  Future<void> fetchCustomGraphStatesByCountry(String country) async {
    _isLoadingCustomGraphStates = true;
    notifyListeners();
    try {
      final response = await http.post(
        Uri.parse('https://countriesnow.space/api/v0.1/countries/states'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'country': country}),
      );
      if (response.statusCode != 200) return;
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>?;
      final states = (data?['states'] as List<dynamic>? ?? const []);
      _customGraphStateOptions
        ..clear()
        ..addAll(
          states
              .map((item) =>
                  (item as Map<String, dynamic>)['name']?.toString() ?? '')
              .where((name) => name.trim().isNotEmpty),
        );
      _customGraphStateOptions
          .sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    } catch (_) {
      _customGraphStateOptions.clear();
    } finally {
      _isLoadingCustomGraphStates = false;
      notifyListeners();
    }
  }

  Future<void> selectCustomGraphCountryAndLoadStates(String country) async {
    _customGraphCountry = country.trim();
    _customGraphState = '';
    _customGraphStateOptions.clear();
    notifyListeners();
    if (_customGraphCountry.isEmpty) return;
    await fetchCustomGraphStatesByCountry(_customGraphCountry);
  }

  Future<void> releaseMovieCountGraph(
    int selectedTimeRange,
    String startDate,
    String endDate, {
    String? contentType,
    String? country,
    String? state,
    String? district,
    String? taluka,
    String? city,
  }) async {
    final localSharePreferences = LocalSharePreferences();
    final mediaHouse = await localSharePreferences.getMediaHouse();
    print(mediaHouse!.mediaHouseName! + ':::::::::MediaHouse:::::::');
    if (selectedTimeRange == 0) {
      isWeek = true;
      isMonth = false;
      isYear = false;
    } else if (selectedTimeRange == 1) {
      isWeek = false;
      isMonth = true;
      isYear = false;
    } else if (selectedTimeRange == 2) {
      isWeek = false;
      isMonth = false;
      isYear = true;
    } else {
      isWeek = false;
      isMonth = false;
      isYear = false;
    }
    String apiUrl = ApiConstant.releaseMovieCountGraphByMediaHouse(
      mediaHouse.id,
      startDate,
      endDate,
      isYear,
      isMonth,
      isWeek,
      contentType: contentType ??
          _normalizeFilter(_customGraphContentType, allAsNull: true),
      country: country ?? _normalizeFilter(_customGraphCountry),
      state: state ?? _normalizeFilter(_customGraphState),
      district: district ?? _normalizeFilter(_customGraphDistrict),
      taluka: taluka ?? _normalizeFilter(_customGraphTaluka),
      city: city ?? _normalizeFilter(_customGraphCity),
    );
    ApiHelper apiHelper = ApiHelper();

    try {
      var response = await apiHelper.getApi(apiUrl);

      Map<String, dynamic> responseBody = json.decode(response.body);

      ChartResponse chartResponse = ChartResponse.fromJson(responseBody);
      final hasData =
          chartResponse.data != null && chartResponse.data!.isNotEmpty;
      if (chartResponse.success == true || hasData) {
        _setNormalizedGraphData(chartResponse.data);
        notifyListeners();
      } else {
        CustomToast.show(chartResponse.message.toString());
      }
    } catch (error) {
      debugPrint("Error occurred while fetching graph data: $error");
      throw Exception('Failed to fetch graph data. Error: $error');
    }
  }

  Future<void> viewsCountGraph(
    int selectedTimeRange,
    String startDate,
    String endDate, {
    String? contentType,
    String? country,
    String? state,
    String? district,
    String? taluka,
    String? city,
  }) async {
    if (selectedTimeRange == 0) {
      isWeek = true;
      isMonth = false;
      isYear = false;
    } else if (selectedTimeRange == 1) {
      isWeek = false;
      isMonth = true;
      isYear = false;
    } else if (selectedTimeRange == 2) {
      isWeek = false;
      isMonth = false;
      isYear = true;
    } else {
      isWeek = false;
      isMonth = false;
      isYear = false;
    }
    final localSharePreferences = LocalSharePreferences();
    final mediaHouse = await localSharePreferences.getMediaHouse();
    print(mediaHouse!.mediaHouseName! + ':::::::::MediaHouse:::::::');
    String apiUrl = ApiConstant.viewCountGraphByMediaHouse(
      mediaHouse.id,
      startDate,
      endDate,
      isYear,
      isMonth,
      isWeek,
      contentType: contentType ??
          _normalizeFilter(_customGraphContentType, allAsNull: true),
      country: country ?? _normalizeFilter(_customGraphCountry),
      state: state ?? _normalizeFilter(_customGraphState),
      district: district ?? _normalizeFilter(_customGraphDistrict),
      taluka: taluka ?? _normalizeFilter(_customGraphTaluka),
      city: city ?? _normalizeFilter(_customGraphCity),
    );
    ApiHelper apiHelper = ApiHelper();

    try {
      var response = await apiHelper.getApi(apiUrl);

      Map<String, dynamic> responseBody = json.decode(response.body);

      ChartResponse chartResponse = ChartResponse.fromJson(responseBody);
      final hasData =
          chartResponse.data != null && chartResponse.data!.isNotEmpty;
      if (chartResponse.success == true || hasData) {
        _setNormalizedGraphData(chartResponse.data);
        notifyListeners();
      } else {
        CustomToast.show(chartResponse.message.toString());
      }
    } catch (error) {
      debugPrint("Error occurred while fetching graph data: $error");
      throw Exception('Failed to fetch graph data. Error: $error');
    }
  }

  // List<Map<String, dynamic>>? revenueCountList = [];
  Future<void> revenueGraphByMediaHouse(
    int selectedTimeRange,
    String startDate,
    String endDate, {
    String? contentType,
    String? country,
    String? state,
    String? district,
    String? taluka,
    String? city,
  }) async {
    final localSharePreferences = LocalSharePreferences();
    final mediaHouse = await localSharePreferences.getMediaHouse();
    print(mediaHouse!.mediaHouseName! + ':::::::::MediaHouse:::::::');
    if (selectedTimeRange == 0) {
      isWeek = true;
      isMonth = false;
      isYear = false;
    } else if (selectedTimeRange == 1) {
      isWeek = false;
      isMonth = true;
      isYear = false;
    } else if (selectedTimeRange == 2) {
      isWeek = false;
      isMonth = false;
      isYear = true;
    } else {
      isWeek = false;
      isMonth = false;
      isYear = false;
    }
    String apiUrl = ApiConstant.revenueGraphByMediaHouse(
      mediaHouse.id,
      startDate,
      endDate,
      isYear,
      isMonth,
      isWeek,
      contentType: contentType ??
          _normalizeFilter(_customGraphContentType, allAsNull: true),
      country: country ?? _normalizeFilter(_customGraphCountry),
      state: state ?? _normalizeFilter(_customGraphState),
      district: district ?? _normalizeFilter(_customGraphDistrict),
      taluka: taluka ?? _normalizeFilter(_customGraphTaluka),
      city: city ?? _normalizeFilter(_customGraphCity),
    );

    debugPrint("✅" + apiUrl);
    ApiHelper apiHelper = ApiHelper();

    try {
      var response = await apiHelper.getApi(apiUrl);
      debugPrint("✅" + response.body);
      Map<String, dynamic> responseBody = json.decode(response.body);

      ChartResponse chartResponse = ChartResponse.fromJson(responseBody);
      final hasData =
          chartResponse.data != null && chartResponse.data!.isNotEmpty;
      if (chartResponse.success == true || hasData) {
        _setNormalizedGraphData(chartResponse.data);
        notifyListeners();
      } else {
        CustomToast.show(chartResponse.message.toString(),
            isSuccess: chartResponse.success!);
      }
    } catch (error) {
      debugPrint("Error occurred while fetching graph data: $error");
      throw Exception('Failed to fetch graph data. Error: $error');
    }
  }

  void _setNormalizedGraphData(List<dynamic>? rawData) {
    graphData.clear();
    if (rawData == null || rawData.isEmpty) return;

    final Map<String, double> merged = <String, double>{};

    for (final item in rawData) {
      final rawLabel = (item.label ?? '').toString().trim();
      final label = rawLabel.isEmpty ? 'N/A' : rawLabel;
      final value = (item.value is num)
          ? (item.value as num).toDouble()
          : double.tryParse('${item.value}') ?? 0.0;

      merged[label] = (merged[label] ?? 0.0) + value;
    }

    merged.forEach((label, value) {
      graphData.add(LineChartData(label, value));
    });
  }
}

class LineChartData {
  final String label;
  final double value;

  LineChartData(this.label, this.value);
}
