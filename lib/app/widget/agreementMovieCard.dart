import 'package:flutter/material.dart';
import 'package:media_house/app/core/utils/agreement_download_helper.dart';
import 'package:media_house/app/core/utils/agreement_template.dart';
import 'package:media_house/app/core/utils/sharepreferences.dart';
import 'package:media_house/app/widget/show_toast.dart';

import '../../domain/entities/content.dart';
import '../ui/pages/movie details page/MovieDetailsPage.dart';

class AgreementMovieCard extends StatelessWidget {
  const AgreementMovieCard({
    super.key,
    required this.movie,
    required this.theme,
  });

  final Content movie;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => _openAgreementDetails(context),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: theme.dividerColor.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _poster(),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                movie.title ?? '',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: theme.canvasColor,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: theme.primaryColor,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                movie.type ?? 'MOVIE',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _agreementLine(
                          'Release Date',
                          (movie.releaseDate ?? 'N/A').toString(),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Download the template and open the agreement screen to complete signature, upload, and fee payment.',
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: theme.canvasColor.withValues(alpha: 0.78),
                            fontSize: 13,
                            height: 1.35,
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    await _downloadAgreementTemplate(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.download_rounded, size: 16),
                  label: const Text('Download Agreement'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _openAgreementDetails(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.primaryColor,
                    side: BorderSide(color: theme.primaryColor),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.description_outlined, size: 16),
                  label: const Text('View Agreement'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _poster() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        width: 116,
        height: 156,
        child: movie.posterUrlList != null && movie.posterUrlList!.isNotEmpty
            ? Image.network(
                movie.posterUrlList!.first,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _errorPoster(),
              )
            : _errorPoster(),
      ),
    );
  }

  Widget _errorPoster() {
    return Container(
      color: Colors.grey.shade300,
      child: const Icon(Icons.movie, size: 42, color: Colors.black54),
    );
  }

  Widget _agreementLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        text: TextSpan(
          style: TextStyle(
            fontSize: 13,
            color: theme.canvasColor.withValues(alpha: 0.82),
          ),
          children: [
            TextSpan(
              text: '$label: ',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: theme.canvasColor,
              ),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  int _seriesEpisodes() {
    final dynamic value = movie.episodeId;
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  void _openAgreementDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MovieDetailsPage(
          movieId: movie.id!,
          initialTab: 3,
        ),
      ),
    );
  }

  Future<void> _downloadAgreementTemplate(BuildContext context) async {
    try {
      final localPrefs = LocalSharePreferences();
      final mediaHouse = await localPrefs.getMediaHouse();
      final bytes = await buildAgreementPdf(
        movie: movie,
        mediaHouse: mediaHouse,
      );
      final safeTitle = (movie.title ?? 'content')
          .replaceAll(RegExp(r'[^A-Za-z0-9]+'), '_')
          .replaceAll(RegExp(r'_+'), '_');
      await saveAgreementFile(bytes, '${safeTitle}_agreement.pdf');
      CustomToast.show('Agreement template downloaded.', isSuccess: true);
    } catch (_) {
      CustomToast.show(
        'Unable to download agreement template.',
        isSuccess: false,
      );
    }
  }
}
