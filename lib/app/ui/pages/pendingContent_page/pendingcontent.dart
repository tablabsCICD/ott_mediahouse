import 'package:flutter/material.dart';
import 'package:media_house/app/provider/themeProvider.dart';
import 'package:media_house/app/widget/movieCardHorizontal.dart';
import 'package:media_house/data/repositories/pendingContent.dart';
import 'package:media_house/device/utils/ResponsiveWidget.dart';
import 'package:provider/provider.dart';

import '../../../../domain/entities/content.dart';
import '../../../core/utils/sharepreferences.dart';
import '../../../provider/videoProvider.dart';

class PendingContentPage extends StatefulWidget {
  @override
  _PendingContentPageState createState() => _PendingContentPageState();
}

class _PendingContentPageState extends State<PendingContentPage> {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = "";
  String? selectedGenre;
  String? selectedLanguage;
  double? selectedRating;
  String selectedStatus = "All"; // Default status
  bool isLoading = true; // Simulating loading state

  @override
  void initState() {
    super.initState();
    // Simulate loading state
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        isLoading = false;
      });
    });

    // Fetch movies with default status on load
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final localSharePreferences = LocalSharePreferences();
      final mediaHouse = await localSharePreferences.getMediaHouse();
      final provider = Provider.of<VideoProvider>(context, listen: false);
      provider.fetchMoviesByStatusAndMediaHouseId(selectedStatus, mediaHouse!.id!);
    });

    // Listen for search query changes
    _searchController.addListener(() {
      setState(() {
        searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }


  Future<void> updateStatus(String status) async {

    setState(() {
      selectedStatus = status;
      isLoading = true; // Display loading during status change
    });
    final localSharePreferences = LocalSharePreferences();
    final mediaHouse = await localSharePreferences.getMediaHouse();
    final provider = Provider.of<VideoProvider>(context, listen: false);
    provider.fetchMoviesByStatusAndMediaHouseId(status,mediaHouse!.id! ).then((_) {
      setState(() {
        isLoading = false; // Loading complete
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: true);
    final selectedThemeData = themeProvider.getTheme;

    return Consumer<VideoProvider>(
      builder: (context, provider, child) {

        return Scaffold(
          backgroundColor: selectedThemeData.scaffoldBackgroundColor,
          body: isLoading
              ? Center(child: CircularProgressIndicator())
              : provider.filteredContentList.isEmpty
              ? Center(
            child: Text(
              "No movies found",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          )
              : Padding(
            padding: const EdgeInsets.only(left: 8.0,right: 8,top: 70,bottom: 10),
            child: ResponsiveWidget.isMobile(context)
                ? ListView.builder(
              itemCount: provider.filteredContentList.length,
              itemBuilder: (context, index) {
                Content movie = provider.filteredContentList[index];
                return MovieCardHorizontal(
                  movie: movie,
                );
              },
            )
                : GridView.builder(
              padding: const EdgeInsets.only(bottom: 12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                mainAxisExtent: 210, // 👈 Perfect fixed height
              ),
              itemCount: provider.filteredContentList.length,
              itemBuilder: (context, index) {
                final movie = provider.filteredContentList[index];
                return MovieCardHorizontal(movie: movie);
              },
            )


          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatusButton("All Uploaded Movies", "all", selectedThemeData),
                _buildStatusButton("Pending Movies", "pending", selectedThemeData),
                _buildStatusButton("Approved Movies", "approved", selectedThemeData),
                _buildStatusButton("Rejected Movies", "rejected", selectedThemeData),
              ],
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerTop,
        );
      },
    );
  }

  Widget _buildStatusButton(String label, String status, ThemeData themeData) {
    return TextButton(
      onPressed: () => updateStatus(status),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: selectedStatus.toLowerCase() == status ? FontWeight.bold : FontWeight.normal,
          color: selectedStatus.toLowerCase() == status
              ? themeData.primaryColor
              : themeData.canvasColor,
        ),
      ),
    );
  }
}
