import 'package:flutter_test/flutter_test.dart';
import 'package:media_house/app/core/content/content_type.dart';
import 'package:media_house/app/ui/pages/uploadContent_page/upload_video.dart';

void main() {
  group('SHORT_FILM contract', () {
    test('uses the exact backend value and Movie-like upload path', () {
      expect(UploadContentType.shortFilm.apiValue, 'SHORT_FILM');
      expect(UploadContentType.shortFilm.displayLabel, 'Short Film');
      expect(UploadContentType.shortFilm.isMovieLike, isTrue);
      expect(UploadContentType.movie.apiValue, 'MOVIE');
      expect(UploadContentType.series.isMovieLike, isFalse);
    });

    test('normalizes, labels and safely handles unknown values', () {
      expect(ContentTypeValue.isMovieLike('short_film'), isTrue);
      expect(ContentTypeValue.displayLabel('SHORT_FILM'), 'Short Film');
      expect(ContentTypeValue.displayLabel('FUTURE_TYPE'), 'FUTURE_TYPE');
      expect(ContentTypeValue.displayLabel(null), 'Unknown');
    });
  });
}
