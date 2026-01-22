import 'package:flutter/material.dart';
import 'package:media_house/app/provider/themeProvider.dart';
import 'package:media_house/app/provider/videoProvider.dart';
import 'package:media_house/app/ui/pages/uploadContent_page/upload_video.dart';
import 'package:media_house/app/widget/custom_textfield.dart';
import 'package:media_house/app/widget/movieCard.dart';
import 'package:media_house/device/utils/ResponsiveWidget.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/sharepreferences.dart';

class ReleasedContentPage extends StatefulWidget {
  @override
  _ReleasedContentPageState createState() => _ReleasedContentPageState();
}

class _ReleasedContentPageState extends State<ReleasedContentPage> {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = "";
  String? selectedGenre;
  String? selectedLanguage;
  double? selectedRating;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _initializeSearchController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() {
      isLoading = true;
    });

    final localSharePreferences = LocalSharePreferences();
    final mediaHouse = await localSharePreferences.getMediaHouse();
    if (mediaHouse != null) {
      await Provider.of<VideoProvider>(context, listen: false)
          .fetchReleasedMoviesByMediaHouseId(mediaHouse.id!);
    }

    setState(() {
      isLoading = false;
    });
  }

  void _initializeSearchController() {
    _searchController.addListener(() {
      setState(() {
        searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  void clearFilters() {
    setState(() {
      selectedGenre = null;
      selectedLanguage = null;
      selectedRating = null;
    });
  }

  void applyFilter(String? genre, String? language, double? rating) {
    setState(() {
      selectedGenre = genre;
      selectedLanguage = language;
      selectedRating = rating;
    });
    Navigator.pop(context); // Close the dialog
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final selectedThemeData = themeProvider.getTheme;

    return Scaffold(
      backgroundColor: selectedThemeData.scaffoldBackgroundColor,
      body: Consumer<VideoProvider>(
        builder: (context, provider, child) {
          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final movies = provider.filteredContentList.where((movie) {
            final title = movie.title?.toLowerCase() ?? "";
            final genres = movie.genreList ?? [];
            final language = movie.languageList ?? "";
            final rating = movie.ratings ?? 0.0;

            return (searchQuery.isEmpty || title.contains(searchQuery)) &&
                (selectedGenre == null || genres.contains(selectedGenre)) &&
                (selectedLanguage == null || language == selectedLanguage) &&
                (selectedRating == null || rating >= selectedRating!);
          }).toList();

          return Stack(
            children: [
              movies.isEmpty
                  ? Center(
                child: Text(
                  "No movies found",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
                  : Padding(
                padding: EdgeInsets.only(
                  bottom: 10,
                  top: 80,
                  left: ResponsiveWidget.isMobile(context) ? 8 : 16,
                  right: ResponsiveWidget.isMobile(context) ? 8 : 16,
                ),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: ResponsiveWidget.isDesktop(context)
                        ? 5
                        : ResponsiveWidget.isTablet(context)
                        ? 4
                        : 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 3 / 5,
                  ),
                  itemCount: movies.length,
                  itemBuilder: (context, index) {
                    final movie = movies[index];
                    return MovieCard(
                      movieId: movie.id!,
                      movieName: movie.title ?? "",
                      poster_url: movie.posterUrlList?.first ?? "",
                      rating: movie.ratings ?? 0.0,
                      rating_count: movie.ratingCount ?? 0,
                      movie:movie
                    );
                  },
                ),
              ),
              Positioned(
                right: 30,
                top: 10,
                child: IconButton(
                  icon: Icon(Icons.file_upload_outlined,
                      color: selectedThemeData.canvasColor),
                  tooltip: "Upload Content",
                  onPressed: () {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) {
                        return Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const UploadVideoWidget(),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: SizedBox(
          width: ResponsiveWidget.isMobile(context) ? double.infinity : 400,
          child: CustomTextField(
            controller: _searchController,
            hintText: "Search movies...",
            prefixIcon: const Icon(Icons.search),
            textInputType: TextInputType.text,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerTop,
    );
  }
}
