import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ContentProvider extends ChangeNotifier {
  // Text controllers
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController releaseDateController = TextEditingController();
  final TextEditingController runtimeController = TextEditingController();
  final TextEditingController languageController = TextEditingController();
  final TextEditingController subtitleLanguageController =
      TextEditingController();
  final TextEditingController directorController = TextEditingController();
  final TextEditingController castController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  // Dropdown and multiple selection values
  String? selectedAgeRating;
  String? selectedContentType;
  String? selectedRentalDuration;
  List<String> selectedGenres = [];
  final List<String> genresOptions = [
    "Action",
    "Drama",
    "Historical",
    "Romantic",
    "Sci-fi",
    "Horror",
    "Comedy",
    "Adventure",
    "Crime"
  ];

  final List<String> ageRatings = [
    "U (unrestricted public exhibition)",
    "UA (required parental guidance for children under age 12)",
    "A (restricted to adults only)"
  ];

  final List<String> contentTypeOptions = [
    "Movie",
    "Short Film",
    "Series",
    "TV Show",
  ];
  final List<String> rentalDurations = [
    "One Time",
    "One Day",
    "Two Day",
    "Three Day",
    "One Week",
    "Two Week",
    "One Month",
    "Three Month",
    "Six Month",
    "One Year",
    "Lifetime",
  ];

  // File upload variables
  Map<String, File?> uploadedFiles = {};

  submit() {}

  void addGenre(String genre) {
    if (!selectedGenres.contains(genre)) {
      selectedGenres.add(genre);
      notifyListeners();
    }
  }

  void removeGenre(String genre) {
    selectedGenres.remove(genre);
    notifyListeners();
  }

  // File upload logic
  Future<void> uploadFile(String label) async {
    if (kIsWeb) {
      // Web-specific logic
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null) {
        uploadedFiles[label] = File(result.files.single.name); // Name for web
      }
    } else if (Platform.isAndroid || Platform.isIOS) {
      // Android and iOS logic
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null) {
        uploadedFiles[label] = File(result.files.single.path!);
      }
    }
    notifyListeners();
  }

  void clearFile(String label) {
    uploadedFiles.remove(label);
    notifyListeners();
  }

  // Cleanup controllers when disposed
  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    releaseDateController.dispose();
    runtimeController.dispose();
    languageController.dispose();
    subtitleLanguageController.dispose();
    directorController.dispose();
    castController.dispose();
    priceController.dispose();
    super.dispose();
  }
}
