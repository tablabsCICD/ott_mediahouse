import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../constant/image_constant.dart';
import '../../../domain/entities/content.dart';
import '../../../domain/entities/mediaHouse.dart';

String _signatoryName(MediaHouse? mediaHouse) {
  final name =
      '${mediaHouse?.director?.firstName ?? ''} ${mediaHouse?.director?.lastName ?? ''}'
          .trim();
  return name.isEmpty ? 'N/A' : name;
}

String _languages(Content movie) {
  final value = (movie.languageList ?? const [])
      .map((e) => e.language ?? '')
      .where((e) => e.trim().isNotEmpty)
      .join(', ');
  return value.isEmpty ? 'N/A' : value;
}

String _genres(Content movie) {
  final value = (movie.genreList ?? const [])
      .where((e) => e.trim().isNotEmpty)
      .join(', ');
  return value.isEmpty ? 'N/A' : value;
}

String _directors(Content movie) {
  final value = (movie.directorList ?? const [])
      .where((e) => e.trim().isNotEmpty)
      .join(', ');
  return value.isEmpty ? 'N/A' : value;
}

String buildAgreementTemplate({
  required Content movie,
  required MediaHouse? mediaHouse,
}) {
  final signedDate = DateFormat('dd MMM yyyy').format(DateTime.now());

  return '''
CONTENT ONBOARDING AGREEMENT

Agreement Date: $signedDate
Platform: Filmytell

This agreement is executed between Filmytell and the production house mentioned below for onboarding audiovisual content for review and possible publication on the platform.

PRODUCTION HOUSE DETAILS
- Name: ${mediaHouse?.mediaHouseName ?? movie.mediaHouseName ?? 'N/A'}
- Firm Type: ${mediaHouse?.firmType ?? 'N/A'}
- Address: ${mediaHouse?.address ?? 'N/A'}
- Email: ${mediaHouse?.email ?? 'N/A'}
- Contact Number: ${mediaHouse?.contactNumber ?? 'N/A'}
- Authorized Signatory: ${_signatoryName(mediaHouse)}

CONTENT DETAILS
- Title: ${movie.title ?? 'N/A'}
- Type: ${movie.type ?? 'N/A'}
- Release Date: ${movie.releaseDate ?? 'N/A'}
- Runtime: ${movie.runtime?.toString() ?? 'N/A'}
- Price: ${movie.price?.toString() ?? 'N/A'}
- Age Rating: ${movie.ageRating ?? 'N/A'}
- Languages: ${_languages(movie)}
- Genres: ${_genres(movie)}
- Directors: ${_directors(movie)}

TERMS AND CONDITIONS
1. The production house confirms that it owns or validly controls the rights required to upload and submit this content for review.
2. The production house confirms that all metadata, certificates, posters, trailers, and uploaded media are accurate and lawful.
3. The production house agrees to sign a hard copy of this agreement and upload the signed scanned copy before the content is moved for admin approval.
4. The production house agrees to pay the applicable onboarding or registration charges before admin approval.
5. Submission of this agreement and payment of onboarding charges does not guarantee approval, publication, or commercial release.
6. The platform may reject, hold, or request corrections if metadata, rights, or policy compliance is incomplete.
7. The production house remains responsible for copyright claims, certification obligations, and all third-party permissions related to the content.

DECLARATION
I/We, the authorized signatory of the above production house, have read and accepted the terms of this agreement.

Authorized Signatory Name: ______________________
Signature: ______________________
Date: ______________________
Place: ______________________
''';
}

pw.Widget _sectionHeading(String title) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 11,
          fontWeight: pw.FontWeight.bold,
          letterSpacing: 0.4,
        ),
      ),
      pw.SizedBox(height: 4),
      pw.Container(height: 0.8, color: PdfColors.grey600),
    ],
  );
}

pw.Widget _detailRows(List<MapEntry<String, String>> items) {
  return pw.Wrap(
    spacing: 14,
    runSpacing: 8,
    children: items
        .map(
          (item) => pw.SizedBox(
            width: 240,
            child: pw.RichText(
              text: pw.TextSpan(
                style: const pw.TextStyle(
                  fontSize: 10.5,
                  color: PdfColors.black,
                ),
                children: [
                  pw.TextSpan(
                    text: '${item.key}: ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.TextSpan(text: item.value),
                ],
              ),
            ),
          ),
        )
        .toList(),
  );
}

Future<Uint8List> buildAgreementPdf({
  required Content movie,
  required MediaHouse? mediaHouse,
}) async {
  final pdf = pw.Document();
  pw.MemoryImage? logoImage;

  try {
    final logoBytes = await rootBundle.load(ImageConstant.logo);
    logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());
  } catch (_) {
    logoImage = null;
  }

  final signedDate = DateFormat('dd MMM yyyy').format(DateTime.now());
  final terms = [
    'The production house confirms that it owns or validly controls the rights required to upload and submit this content for review.',
    'The production house confirms that all metadata, certificates, posters, trailers, and uploaded media are accurate and lawful.',
    'The production house agrees to sign a hard copy of this agreement and upload the signed scanned copy before the content is moved for admin approval.',
    'The production house agrees to pay the applicable onboarding or registration charges before admin approval.',
    'Submission of this agreement and payment of onboarding charges does not guarantee approval, publication, or commercial release.',
    'The platform may reject, hold, or request corrections if metadata, rights, or policy compliance is incomplete.',
    'The production house remains responsible for copyright claims, certification obligations, and all third-party permissions related to the content.',
  ];

  final List<MapEntry<String, String>> productionHouseDetails = [
    MapEntry(
      'Production House',
      (mediaHouse?.mediaHouseName ?? movie.mediaHouseName ?? 'N/A').toString(),
    ),
    MapEntry('Firm Type', '${mediaHouse?.firmType ?? 'N/A'}'),
    MapEntry('Address', (mediaHouse?.address ?? 'N/A').toString()),
    MapEntry('Email', (mediaHouse?.email ?? 'N/A').toString()),
    MapEntry(
      'Contact Number',
      (mediaHouse?.contactNumber ?? 'N/A').toString(),
    ),
    MapEntry('Authorized Signatory', _signatoryName(mediaHouse)),
  ];

  final List<MapEntry<String, String>> contentDetails = [
    MapEntry('Title', (movie.title ?? 'N/A').toString()),
    MapEntry('Type', (movie.type ?? 'N/A').toString()),
    MapEntry('Release Date', (movie.releaseDate ?? 'N/A').toString()),
    MapEntry('Runtime', (movie.runtime?.toString() ?? 'N/A').toString()),
    MapEntry('Price', (movie.price?.toString() ?? 'N/A').toString()),
    MapEntry('Age Rating', (movie.ageRating ?? 'N/A').toString()),
    MapEntry('Languages', _languages(movie)),
    MapEntry('Genres', _genres(movie)),
    MapEntry('Directors', _directors(movie)),
  ];

  pdf.addPage(
    pw.MultiPage(
      pageTheme: pw.PageTheme(
        margin: const pw.EdgeInsets.fromLTRB(36, 32, 36, 34),
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(
          base: pw.Font.helvetica(),
          bold: pw.Font.helveticaBold(),
        ),
      ),
      build: (context) => [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            if (logoImage != null)
              pw.Container(
                width: 72,
                alignment: pw.Alignment.centerLeft,
                child: pw.Image(logoImage, height: 36, fit: pw.BoxFit.contain),
              ),
            if (logoImage != null) pw.SizedBox(width: 12),
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'CONTENT ONBOARDING AGREEMENT',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    'Filmytell',
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey700,
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(
              width: 120,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    'Agreement Date',
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.SizedBox(height: 3),
                  pw.Text(
                    signedDate,
                    style: pw.TextStyle(
                      fontSize: 10.5,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 12),
        pw.Container(height: 1, color: PdfColors.grey700),
        pw.SizedBox(height: 14),
        pw.Text(
          'This agreement is executed between Filmytell and the production house mentioned below for onboarding audiovisual content for review and possible publication on the platform.',
          style: const pw.TextStyle(fontSize: 10.5),
        ),
        pw.SizedBox(height: 16),
        _sectionHeading('PRODUCTION HOUSE DETAILS'),
        pw.SizedBox(height: 10),
        _detailRows(productionHouseDetails),
        pw.SizedBox(height: 16),
        _sectionHeading('CONTENT DETAILS'),
        pw.SizedBox(height: 10),
        _detailRows(contentDetails),
        pw.SizedBox(height: 16),
        _sectionHeading('TERMS AND CONDITIONS'),
        pw.SizedBox(height: 10),
        ...List.generate(
          terms.length,
          (index) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 8),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(
                  width: 16,
                  child: pw.Text(
                    '${index + 1}.',
                    style: pw.TextStyle(
                      fontSize: 10.5,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.Expanded(
                  child: pw.Text(
                    terms[index],
                    style: const pw.TextStyle(fontSize: 10.5),
                  ),
                ),
              ],
            ),
          ),
        ),
        pw.SizedBox(height: 16),
        _sectionHeading('DECLARATION'),
        pw.SizedBox(height: 8),
        pw.Text(
          'I/We, the authorized signatory of the above production house, have read and accepted the terms of this agreement.',
          style: const pw.TextStyle(fontSize: 10.5),
        ),
        pw.SizedBox(height: 22),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.SizedBox(height: 28),
                  pw.Container(height: 0.8, color: PdfColors.grey700),
                  pw.SizedBox(height: 6),
                  pw.Text(
                    'Authorized Signatory Name & Signature',
                    style: const pw.TextStyle(fontSize: 9.5),
                  ),
                ],
              ),
            ),
            pw.SizedBox(width: 18),
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Date: ____________________',
                    style: const pw.TextStyle(fontSize: 10.5),
                  ),
                  pw.SizedBox(height: 12),
                  pw.Text(
                    'Place: ____________________',
                    style: const pw.TextStyle(fontSize: 10.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );

  return pdf.save();
}
