class ImageValidationConstants {
  ImageValidationConstants._();

  // Poster
  static const int posterWidth = 1080;
  static const int posterHeight = 1620;
  static const double posterAspectRatio = 2 / 3;
  static const int posterMaxSizeMB = 2;
  static const int posterMinSizeKB = 50;

  // Banner
  static const int bannerWidth = 1920;
  static const int bannerHeight = 1080;
  static const double bannerAspectRatio = 16 / 9;
  static const int bannerMaxSizeMB = 5;

  // TV Banner
  static const int tvBannerWidth = 320;
  static const int tvBannerHeight = 180;

  // Thumbnail
  static const int thumbnailWidth = 1280;
  static const int thumbnailHeight = 720;
  static const double thumbnailAspectRatio = 16 / 9;
  static const int thumbnailMaxSizeMB = 5;

  // Formats
  static const List<String> commonImageFormats = ['jpg', 'jpeg', 'png', 'webp'];
  static const List<String> tvBannerFormats = ['png'];

  // Messages
  static const String invalidCommonFormat =
      'Only JPG, JPEG, PNG and WEBP images are allowed.';
  static const String invalidTvBannerFormat =
      'TV banner must match the required dimensions and be in PNG format.';
  static const String invalidPosterSize =
      'Image size must be between 50 KB and 2 MB.';
  static const String invalidBannerSize = 'Image size must be 5 MB or smaller.';
  static const String invalidThumbnailSize =
      'Thumbnail size must be 5 MB or smaller.';
  static const String invalidPosterDimensions =
      'Poster image must match the required dimensions or aspect ratio.';
  static const String invalidBannerDimensions =
      'Banner image must match the required banner dimensions.';
  static const String invalidThumbnailDimensions =
      'Thumbnail image must match the required thumbnail dimensions.';
  static const String invalidImage = 'Selected file is not a valid image.';

  static String get posterGuideline =>
      'Recommended Size: $posterWidth x $posterHeight px';
  static String get bannerGuideline =>
      'Recommended Size: $bannerWidth x $bannerHeight px';
  static String get tvBannerGuideline =>
      'Required Size: $tvBannerWidth x $tvBannerHeight px';
  static String get thumbnailGuideline =>
      'Recommended Size: $thumbnailWidth x $thumbnailHeight px';
}
