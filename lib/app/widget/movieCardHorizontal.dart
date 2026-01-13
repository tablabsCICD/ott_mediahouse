import 'package:flutter/material.dart';
import 'package:media_house/app/provider/themeProvider.dart';
import 'package:media_house/app/ui/pages/movie%20details%20page/pendingMovieDetailsPage.dart';
import 'package:media_house/app/widget/show_toast.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/content.dart';
import '../ui/pages/movie details page/MovieDetailsPage.dart';
import '../ui/pages/movie details page/component/setPercentageDialog.dart';

class MovieCardHorizontal extends StatelessWidget {
  final Content movie;

  const MovieCardHorizontal({
    Key? key,
    required this.movie,

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: true);
    final selectedThemeData = themeProvider.getTheme;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (content) => MovieDetailsPage(movieId: movie.id!),
          ),
        );
      },
      child: Card(
        color: selectedThemeData.cardColor,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: movie.posterUrlList != null && movie.posterUrlList!.isNotEmpty
                      ? Image.network(
                    movie.posterUrlList![0],
                    width: 100,
                    height: 140,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.broken_image,
                      size: 100,
                      color: Colors.grey,
                    ),
                  )
                      : Container(
                    width: 100,
                    height: 140,
                    color: Colors.grey[300],
                    child: Icon(
                      Icons.movie,
                      size: 60,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        movie.title??'',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Director(s): ${movie.directorList!.isNotEmpty ? movie.directorList!.join(', ') : "Unknown"}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Cast: ${movie.castList!.isNotEmpty ? movie.castList!.join(', ') : "No cast information available"}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            "${movie.ratings} (${movie.ratingCount} reviews)",
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    /*  SizedBox(height: 10,),
                      movie.approvalStatus!.toLowerCase()=="approved".toLowerCase()? SizedBox.shrink():ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedThemeData.primaryColor,
                        ),
                        onPressed: () => showSetPercentageDialog(context,movie),
                        child: const Text("Add Movie Percentage"),
                      ),
                    */],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  showSetPercentageDialog(BuildContext context,
      Content content) async {
    final double? result = await showDialog<double>(
      context: context,
      builder: (BuildContext context) {
        return SetPercentageDialog(
            content:content
        );
      },
    );

    if (result != null) {
      debugPrint("Selected Percentage: ${result.toInt()}%");

      CustomToast.show('Selected Percentage : ${result.toInt()}%',isSuccess: false);
    }
  }
}
