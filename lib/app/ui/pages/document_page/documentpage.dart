import 'package:flutter/material.dart';
import 'package:media_house/app/provider/mediaHouseProvider.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';
import 'package:media_house/app/provider/themeProvider.dart';

class DocumentsPage extends StatefulWidget {
  const DocumentsPage({super.key});

  @override
  State<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  static const List<String> _registrationDocumentOrder = [
    'Registration Certificate',
    'Aadhaar Card',
    'Pan Card',
    'GST Certificate',
    'Shop Act',
    'Bank Proof',
    'Identity Proof',
    'Address Proof',
  ];

  String? _getFileUrl(dynamic raw) {
    if (raw == null) return null;
    final value = raw.toString().trim();
    if (value.isEmpty || value.toLowerCase() == "null") return null;
    return value;
  }

  String? _resolveDocumentUrl(MediaHouseProvider provider, String docType) {
    final fromMap = _getFileUrl(provider.uploadedDocuments[docType]?['file']);
    if (fromMap != null) return fromMap;

    final media = provider.mediaHouse;
    switch (docType) {
      case 'Registration Certificate':
        return _getFileUrl(media.registrationCertificate);
      case 'Aadhaar Card':
        return _getFileUrl(media.adharCard);
      case 'Pan Card':
        return _getFileUrl(media.panCard);
      case 'GST Certificate':
        return _getFileUrl(media.gstCertificates);
      case 'Shop Act':
        return _getFileUrl(media.shopAct);
      case 'Bank Proof':
        return _getFileUrl(media.bankProof);
      case 'Identity Proof':
        return _getFileUrl(media.identityProof);
      case 'Address Proof':
        return _getFileUrl(media.addressProof);
      default:
        return null;
    }
  }

  Future<void> viewDocument(String fileUrl) async {
    if (fileUrl.isNotEmpty) {
      await OpenFile.open(fileUrl);
    }
  }

  void removeDocument(BuildContext context, String docType,
      MediaHouseProvider provider, String title) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content:
              Text('Are you sure you want to remove the $docType document?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Dismiss the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Proceed with document removal
                await provider.clearController(title);
                await provider.updateMediaHouseDocument();
                setState(() {
                  provider.uploadedDocuments[docType]?['file'] = null;
                  provider.uploadedDocuments[docType]?['fileName'] = '';
                  provider.uploadedDocuments[docType]?['fileSize'] = '';
                });

                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop(); // Dismiss the dialog
                }
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var selectedThemeData =
        Provider.of<ThemeProvider>(context, listen: true).getTheme;
    return Consumer<MediaHouseProvider>(builder: (context, provider, child) {
      final keys = List<String>.from(_registrationDocumentOrder);
      return Scaffold(
        backgroundColor: selectedThemeData.scaffoldBackgroundColor,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Documents",
                  style: TextStyle(
                    color: selectedThemeData.canvasColor,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Upload and manage your verification documents.",
                  style: TextStyle(
                    color:
                        selectedThemeData.canvasColor.withValues(alpha: 0.65),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: LayoutBuilder(
                    builder: (_, constraints) {
                      final width = constraints.maxWidth;
                      final crossAxisCount = width >= 1200
                          ? 3
                          : width >= 760
                              ? 2
                              : 1;

                      return GridView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: keys.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: width < 500 ? 1.05 : 1.2,
                        ),
                        itemBuilder: (context, index) {
                          final docType = keys[index];
                          final fileUrl =
                              _resolveDocumentUrl(provider, docType);
                          final isUploaded = fileUrl != null;
                          final description = provider
                                  .uploadedDocuments[docType]?['description']
                                  ?.toString() ??
                              "Upload $docType";

                          return Material(
                            color: selectedThemeData.cardColor,
                            borderRadius: BorderRadius.circular(18),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(18),
                              onTap: () async {
                                if (isUploaded) {
                                  await viewDocument(fileUrl);
                                } else {
                                  await provider.pickImage(docType);
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: AspectRatio(
                                        aspectRatio: 16 / 9,
                                        child: Container(
                                          color: selectedThemeData.primaryColor
                                              .withValues(alpha: 0.08),
                                          child: isUploaded
                                              ? Image.network(
                                                  fileUrl,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (_, __, ___) =>
                                                      Icon(
                                                    Icons.description_outlined,
                                                    size: 34,
                                                    color: selectedThemeData
                                                        .primaryColor,
                                                  ),
                                                )
                                              : Icon(
                                                  Icons.upload_file_rounded,
                                                  size: 34,
                                                  color: selectedThemeData
                                                      .primaryColor,
                                                ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      docType,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: selectedThemeData.canvasColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      description,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: selectedThemeData.canvasColor
                                            .withValues(alpha: 0.65),
                                        fontSize: 12,
                                      ),
                                    ),
                                    const Spacer(),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: selectedThemeData
                                                  .primaryColor,
                                              foregroundColor: Colors.white,
                                            ),
                                            onPressed: () async {
                                              if (isUploaded) {
                                                await viewDocument(fileUrl);
                                              } else {
                                                await provider
                                                    .pickImage(docType);
                                              }
                                            },
                                            icon: Icon(isUploaded
                                                ? Icons.visibility_rounded
                                                : Icons.cloud_upload_rounded),
                                            label: Text(
                                                isUploaded ? "View" : "Upload"),
                                          ),
                                        ),
                                        if (isUploaded) ...[
                                          const SizedBox(width: 8),
                                          IconButton(
                                            style: IconButton.styleFrom(
                                              backgroundColor: selectedThemeData
                                                  .primaryColor
                                                  .withValues(alpha: 0.1),
                                              foregroundColor: selectedThemeData
                                                  .primaryColor,
                                            ),
                                            onPressed: () => removeDocument(
                                                context,
                                                docType,
                                                provider,
                                                docType.toString()),
                                            icon: const Icon(
                                                Icons.delete_outline),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
