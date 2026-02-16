import 'package:flutter/material.dart';
import 'package:media_house/app/provider/themeProvider.dart';
import 'package:media_house/app/provider/videoProvider.dart';
import 'package:media_house/app/ui/pages/uploadContent_page/upload_video.dart';
import 'package:media_house/app/widget/custom_textfield.dart';
import 'package:media_house/app/widget/movieCard.dart';
import 'package:media_house/device/utils/ResponsiveWidget.dart';
import 'package:provider/provider.dart';
import '../../../../domain/entities/content.dart';
import '../../../core/utils/sharepreferences.dart';

class ReleasedContentPage extends StatefulWidget {
  const ReleasedContentPage({super.key});

  @override
  State<ReleasedContentPage> createState() => _ReleasedContentPageState();
}

class _ReleasedContentPageState extends State<ReleasedContentPage> {
  String selectedContentType = "MOVIE";
  String? selectedGenre;
  String? selectedLanguage;
  double? selectedRating;
  bool isLoading = true;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    _fetchData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() {
      isLoading = true;
    });

    final localSharePreferences = LocalSharePreferences();
    final mediaHouse = await localSharePreferences.getMediaHouse();
    if (!mounted) return;

    if (mediaHouse != null) {
      final provider = Provider.of<VideoProvider>(context, listen: false);
      provider.setItemsPerPage(10);
      provider.resetPagination();
      await provider.fetchReleasedMoviesByMediaHouseId(mediaHouse.id!);
    }

    if (!mounted) return;
    setState(() {
      isLoading = false;
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      _loadMoreItems();
    }
  }

  void _loadMoreItems() {
    final provider = Provider.of<VideoProvider>(context, listen: false);
    final movies = _filteredMovies(provider);
    if (provider.hasMoreForCount(movies.length) && !provider.isLoadingMore) {
      provider.loadNextPageForCount(movies.length);
    }
  }

  bool _isSeries(Content movie) {
    final type = (movie.type ?? "").toLowerCase();
    return type.contains("series") || movie.seasonId != null;
  }

  List<Content> _filteredMovies(VideoProvider provider) {
    final query = provider.searchContentController.text.toLowerCase();

    return provider.filteredContentList.where((movie) {
      final title = movie.title?.toLowerCase() ?? "";
      final genres = movie.genreList ?? <String>[];
      final rating = movie.ratings ?? 0.0;
      final movieLanguages = movie.languageList ?? [];
      final isSeries = _isSeries(movie);
      final typeMatches = selectedContentType == "SERIES" ? isSeries : !isSeries;

      final languageMatches = selectedLanguage == null ||
          movieLanguages.any((lang) =>
              (lang.language ?? '').toLowerCase() ==
              selectedLanguage!.toLowerCase());

      return typeMatches &&
          (query.isEmpty || title.contains(query)) &&
          (selectedGenre == null || genres.contains(selectedGenre)) &&
          languageMatches &&
          (selectedRating == null || rating >= selectedRating!);
    }).toList();
  }

  void clearFilters() {
    setState(() {
      selectedGenre = null;
      selectedLanguage = null;
      selectedRating = null;
    });
    Provider.of<VideoProvider>(context, listen: false).resetPagination();
  }

  void applyFilter(String? genre, String? language, double? rating) {
    setState(() {
      selectedGenre = genre;
      selectedLanguage = language;
      selectedRating = rating;
    });
    Provider.of<VideoProvider>(context, listen: false).resetPagination();
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

          final movies = _filteredMovies(provider);
          final displayedCount = provider.visibleCountFor(movies.length);
          final displayedItems = movies.take(displayedCount).toList();

          return Stack(
            children: [
              displayedItems.isEmpty
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
                  controller: _scrollController,
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
                  itemCount:
                  displayedItems.length + (provider.isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == displayedItems.length) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final movie = displayedItems[index];
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
                left: 16,
                top: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                    color: selectedThemeData.cardColor,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      ChoiceChip(
                        label: const Text("Movies"),
                        selected: selectedContentType == "MOVIE",
                        selectedColor: selectedThemeData.primaryColor,
                        labelStyle: TextStyle(
                          color: selectedContentType == "MOVIE"
                              ? selectedThemeData.scaffoldBackgroundColor
                              : selectedThemeData.primaryColor,
                        ),
                        onSelected: (_) {
                          setState(() {
                            selectedContentType = "MOVIE";
                          });
                          Provider.of<VideoProvider>(context, listen: false)
                              .resetPagination();
                        },
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text("Series"),
                        selected: selectedContentType == "SERIES",
                        selectedColor: selectedThemeData.primaryColor,
                        labelStyle: TextStyle(
                          color: selectedContentType == "SERIES"
                              ? selectedThemeData.scaffoldBackgroundColor
                              : selectedThemeData.primaryColor,
                        ),
                        onSelected: (_) {
                          setState(() {
                            selectedContentType = "SERIES";
                          });
                          Provider.of<VideoProvider>(context, listen: false)
                              .resetPagination();
                        },
                      ),
                    ],
                  ),
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
            controller:
            Provider.of<VideoProvider>(context, listen: false)
                .searchContentController,
            hintText: "Search released content...",
            prefixIcon: const Icon(Icons.search),
            onValueChange: (_) {
              Provider.of<VideoProvider>(context, listen: false)
                  .resetPagination();
            },
            textInputType: TextInputType.text,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerTop,
    );
  }
}
