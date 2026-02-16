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

  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

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
      provider.setItemsPerPage(10);
      provider.fetchMoviesByStatusAndMediaHouseId(selectedStatus, mediaHouse!.id!);
    });

    // Listen for search query changes
    _searchController.addListener(() {
      setState(() {
        searchQuery = _searchController.text.toLowerCase();
      });
      final provider = Provider.of<VideoProvider>(context, listen: false);
      provider.resetPagination();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreItems();
    }
  }

  void _loadMoreItems() {
    final provider = Provider.of<VideoProvider>(context, listen: false);
    if (provider.hasMoreItems && !provider.isLoadingMore) {
      provider.loadNextPage();
    }
  }

  Future<void> updateStatus(String status) async {
    setState(() {
      selectedStatus = status;
      isLoading = true;
    });
    final localSharePreferences = LocalSharePreferences();
    final mediaHouse = await localSharePreferences.getMediaHouse();
    final provider = Provider.of<VideoProvider>(context, listen: false);
    provider.resetPagination();
    provider.fetchMoviesByStatusAndMediaHouseId(status, mediaHouse!.id!).then((_) {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: true);
    final selectedThemeData = themeProvider.getTheme;

    return Consumer<VideoProvider>(
      builder: (context, provider, child) {
        final displayedItems = provider.getAllItemsUpToCurrentPage();
        final hasMoreItems = provider.hasMoreItems;

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
            padding: const EdgeInsets.only(left: 8.0, right: 8, top: 70, bottom: 10),
            child: ResponsiveWidget.isMobile(context)
                ? ListView.builder(
              controller: _scrollController,
              itemCount: displayedItems.length + (hasMoreItems ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == displayedItems.length) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 12),
                        Text(
                          provider.getPageInfo(),
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  );
                }
                Content movie = displayedItems[index];
                return MovieCardHorizontal(movie: movie);
              },
            )
                : Stack(
              children: [
                GridView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(bottom: 12),
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    mainAxisExtent: 210,
                  ),
                  itemCount: displayedItems.length,
                  itemBuilder: (context, index) {
                    final movie = displayedItems[index];
                    return MovieCardHorizontal(movie: movie);
                  },
                ),
                if (hasMoreItems)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 8),
                          Text(
                            provider.getPageInfo(),
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
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