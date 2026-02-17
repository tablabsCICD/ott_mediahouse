import 'package:flutter/material.dart';
import 'package:media_house/app/provider/themeProvider.dart';
import 'package:media_house/app/provider/videoProvider.dart';
import 'package:media_house/app/ui/pages/uploadContent_page/select_upload_type.dart';
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
  bool isLoading = true;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _fetchData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    try {
      final localPrefs = LocalSharePreferences();
      final mediaHouse = await localPrefs.getMediaHouse();

      if (mediaHouse != null) {
        final provider = Provider.of<VideoProvider>(context, listen: false);
        provider.searchContentController.clear();
        provider.setItemsPerPage(12);
        provider.resetPagination();
        await provider.fetchMoviesByMediaHouseId(mediaHouse.id!);
      }
    } catch (error) {
      debugPrint("Failed to fetch released content: $error");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
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
      final isSeries = _isSeries(movie);
      final typeMatches =
          selectedContentType == "SERIES" ? isSeries : !isSeries;

      return typeMatches && (query.isEmpty || title.contains(query));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).getTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Consumer<VideoProvider>(
          builder: (context, provider, _) {
            if (isLoading) {
              return Center(
                  child: CircularProgressIndicator(
                color: theme.primaryColor,
              ));
            }

            final movies = _filteredMovies(provider);

            return Column(
              children: [
                /// 🔥 Header Section
                _buildHeader(context, theme, provider),

                const SizedBox(height: 12),

                /// 🎬 Grid Section
                Expanded(
                  child: movies.isEmpty
                      ? const Center(
                          child: Text("No content found"),
                        )
                      : Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                ResponsiveWidget.isDesktop(context) ? 20 : 8,
                          ),
                          child: GridView.builder(
                            controller: _scrollController,
                            gridDelegate:
                                SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 400,
                              crossAxisSpacing: 6,
                              mainAxisSpacing: 8,
                              childAspectRatio: 16 / 9,
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
                                movie: movie,
                              );
                            },
                          ),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, ThemeData theme, VideoProvider provider) {
    final isDesktop = ResponsiveWidget.isDesktop(context);
    final isTablet = ResponsiveWidget.isTablet(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 40 : 16,
        vertical: 16,
      ),
      child: isDesktop || isTablet
          ? Row(
              children: [
                Expanded(
                  flex: 3,
                  child: CustomTextField(
                    controller: provider.searchContentController,
                    hintText: "Search released content...",
                    prefixIcon: const Icon(Icons.search),
                    textInputType: TextInputType.text,
                    onValueChange: (_) => provider.resetPagination(),
                  ),
                ),
                const SizedBox(width: 20),
                _buildTypeChips(theme),
                const SizedBox(width: 20),
                _buildUploadButton(theme),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomTextField(
                  controller: provider.searchContentController,
                  hintText: "Search released content...",
                  prefixIcon: const Icon(Icons.search),
                  textInputType: TextInputType.text,
                  onValueChange: (_) => provider.resetPagination(),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTypeChips(theme),
                    _buildUploadButton(theme),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildTypeChips(ThemeData theme) {
    return Row(
      children: [
        ChoiceChip(
          label: const Text("Movies"),
          selected: selectedContentType == "MOVIE",
          selectedColor: theme.primaryColor,
          labelStyle: TextStyle(
            color: selectedContentType == "MOVIE"
                ? Colors.white
                : theme.primaryColor,
          ),
          onSelected: (_) => setState(() => selectedContentType = "MOVIE"),
        ),
        const SizedBox(width: 10),
        ChoiceChip(
          label: const Text("Series"),
          selected: selectedContentType == "SERIES",
          selectedColor: theme.primaryColor,
          labelStyle: TextStyle(
            color: selectedContentType == "SERIES"
                ? Colors.white
                : theme.primaryColor,
          ),
          onSelected: (_) => setState(() => selectedContentType = "SERIES"),
        ),
      ],
    );
  }

  Widget _buildUploadButton(ThemeData theme) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
      ),
      icon: const Icon(Icons.file_upload_outlined),
      label: const Text("Upload"),
      onPressed: () {
        showDialog(
          context: context,
          builder: (_) => const SelectUploadTypeDialog(),
        );
      },
    );
  }
}
