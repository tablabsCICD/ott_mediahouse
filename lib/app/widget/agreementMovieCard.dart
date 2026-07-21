import 'package:flutter/material.dart';
import 'package:media_house/app/core/utils/agreement_download_helper.dart';
import 'package:media_house/app/core/utils/agreement_template.dart';
import 'package:media_house/app/core/utils/sharepreferences.dart';
import 'package:media_house/app/ui/pages/sereis/components/series_details_page.dart';
import 'package:media_house/app/ui/pages/shorts/components/short_master_page.dart';
import 'package:media_house/app/widget/show_toast.dart';

import '../../domain/entities/content.dart';
import '../ui/pages/movie details page/MovieDetailsPage.dart';
import '../core/content/content_type.dart';

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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              movie.title ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: theme.canvasColor,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (_languageLabel().isNotEmpty) _languageBadge(),
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
                  icon: const Icon(Icons.upload_file_outlined, size: 16),
                  label: const Text('Upload Agreement'),
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

  Widget _languageBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.primaryColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: theme.primaryColor.withValues(alpha: 0.32)),
      ),
      child: Text(
        _languageLabel(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: theme.primaryColor,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  String _languageLabel() {
    final languages = movie.languageList
            ?.map((item) => (item.language ?? '').trim())
            .where((item) => item.isNotEmpty)
            .toList() ??
        [];
    if (languages.isEmpty) return '';
    if (languages.length == 1) return languages.first;
    return '${languages.first} +${languages.length - 1}';
  }

  void _openAgreementDetails(BuildContext context) {
    if (ContentTypeValue.isMovieLike(movie.type)) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MovieDetailsPage(movieId: movie.id!),
        ),
      );
      return;
    }
    if (movie.type == "SERIES") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SeriesDetailsPage(
            seriesId: movie.id!,
            content: movie,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ShortMasterPage(
            shortId: movie.id!,
          ),
        ),
      );
    }
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
      CustomToast.show(context, 'Agreement template downloaded.',
          isSuccess: true);
    } catch (_) {
      CustomToast.show(
        context,
        'Unable to download agreement template.',
        isSuccess: false,
      );
    }
  }
}
