import 'dart:convert';
import 'dart:io' as io;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:media_house/data/models/response/series_detail_response.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as html;

import '../../../../core/constant/api_constant.dart';
import '../../../../../data/models/response/content_image_upload_response.dart';
import '../../../../provider/themeProvider.dart';

class EditSeasonDialog extends StatefulWidget {
  final Season season;

  const EditSeasonDialog({
    super.key,
    required this.season,
  });

  @override
  State<EditSeasonDialog> createState() => _EditSeasonDialogState();
}

class _EditSeasonDialogState extends State<EditSeasonDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _amountCtrl;
  late final TextEditingController _seasonNoCtrl;
  late final TextEditingController _posterUrlCtrl;
  DateTime _releaseDate = DateTime.now();
  Uint8List? _previewBytes;
  bool _isUploadingPoster = false;
  double _uploadProgress = 0;

  @override
  void initState() {
    super.initState();
    final s = widget.season;
    _titleCtrl = TextEditingController(text: s.title ?? '');
    _descCtrl = TextEditingController(text: s.description ?? '');
    _amountCtrl = TextEditingController(text: '${s.amount ?? 0}');
    _seasonNoCtrl = TextEditingController(text: '${s.seasonNumber ?? 1}');
    _posterUrlCtrl = TextEditingController(text: '${s.posterUrl ?? ''}');

    final epoch = s.releaseDate;
    if (epoch != null && epoch > 0) {
      try {
        _releaseDate = DateTime.fromMillisecondsSinceEpoch(epoch);
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _amountCtrl.dispose();
    _seasonNoCtrl.dispose();
    _posterUrlCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context, listen: false).getTheme;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 780, maxHeight: 720),
        child: Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(20),
            border:
                Border.all(color: theme.dividerColor.withValues(alpha: 0.35)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 24,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
                    gradient: LinearGradient(
                      colors: [
                        theme.primaryColor.withValues(alpha: 0.12),
                        theme.primaryColor.withValues(alpha: 0.04),
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 34,
                        width: 34,
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.edit_outlined,
                            color: theme.primaryColor),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Edit Season',
                        style: TextStyle(
                          color: theme.canvasColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close, color: theme.canvasColor),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionCard(
                          theme: theme,
                          title: 'Basic Details',
                          children: [
                            _field(
                              _titleCtrl,
                              'Season Title',
                              validator: (v) {
                                final t = (v ?? '').trim();
                                if (t.isEmpty) {
                                  return 'Season title is required';
                                }
                                if (t.length < 2) {
                                  return 'Enter valid season title';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            _field(
                              _descCtrl,
                              'Description',
                              maxLines: 4,
                              validator: (v) {
                                final t = (v ?? '').trim();
                                if (t.isEmpty) return 'Description is required';
                                if (t.length < 5) {
                                  return 'Description is too short';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _sectionCard(
                          theme: theme,
                          title: 'Pricing & Sequence',
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _field(
                                    _amountCtrl,
                                    'Season Price',
                                    keyboardType: TextInputType.number,
                                    validator: (v) {
                                      final n = num.tryParse((v ?? '').trim());
                                      if (n == null) {
                                        return 'Enter valid amount';
                                      }
                                      if (n < 0) {
                                        return 'Amount cannot be negative';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _field(
                                    _seasonNoCtrl,
                                    'Season Number',
                                    keyboardType: TextInputType.number,
                                    validator: (v) {
                                      final n = int.tryParse((v ?? '').trim());
                                      if (n == null) return 'Enter number';
                                      if (n <= 0) return 'Must be > 0';
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _sectionCard(
                          theme: theme,
                          title: 'Media & Release',
                          children: [
                            _posterUploadCard(theme),
                            const SizedBox(height: 12),
                            _field(
                              _posterUrlCtrl,
                              'Poster URL',
                              validator: (v) {
                                if ((v ?? '').trim().isEmpty) {
                                  return 'Poster URL is required';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            InkWell(
                              onTap: _pickDate,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 16),
                                decoration: BoxDecoration(
                                  color: theme.scaffoldBackgroundColor
                                      .withValues(alpha: 0.35),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: theme.dividerColor
                                        .withValues(alpha: 0.4),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.event,
                                        color: theme.primaryColor, size: 18),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Release Date: ${DateFormat('dd MMM yyyy').format(_releaseDate)}',
                                      style: TextStyle(
                                        color: theme.canvasColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                          color: theme.dividerColor.withValues(alpha: 0.3)),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Save Changes'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionCard({
    required ThemeData theme,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: theme.primaryColor,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final theme = Provider.of<ThemeProvider>(context, listen: false).getTheme;
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.transparent,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: theme.canvasColor),
        ),
      ),
    );
  }

  Widget _posterUploadCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Season Poster',
            style: TextStyle(
              color: theme.canvasColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: 140,
              width: double.infinity,
              child: _previewBytes != null
                  ? Image.memory(_previewBytes!, fit: BoxFit.cover)
                  : (_posterUrlCtrl.text.trim().isNotEmpty
                      ? Image.network(
                          _posterUrlCtrl.text.trim(),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _posterPlaceholder(theme),
                        )
                      : _posterPlaceholder(theme)),
            ),
          ),
          if (_isUploadingPoster) ...[
            const SizedBox(height: 10),
            LinearProgressIndicator(value: _uploadProgress),
          ],
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _isUploadingPoster ? null : _pickPosterImage,
            icon: const Icon(Icons.upload_file_rounded, size: 18),
            label: Text(_isUploadingPoster ? 'Uploading...' : 'Pick & Upload'),
          ),
        ],
      ),
    );
  }

  Widget _posterPlaceholder(ThemeData theme) {
    return Container(
      color: theme.scaffoldBackgroundColor.withValues(alpha: 0.35),
      alignment: Alignment.center,
      child: Icon(
        Icons.image_outlined,
        size: 34,
        color: theme.canvasColor.withValues(alpha: 0.5),
      ),
    );
  }

  Future<void> _pickPosterImage() async {
    if (_isUploadingPoster) return;
    if (kIsWeb) {
      final input = html.FileUploadInputElement()..accept = 'image/*';
      input.click();
      input.onChange.listen((_) async {
        final file =
            input.files?.isNotEmpty == true ? input.files!.first : null;
        if (file == null) return;
        final reader = html.FileReader();
        reader.readAsArrayBuffer(file);
        await reader.onLoad.first;
        final bytes = Uint8List.fromList((reader.result as List).cast<int>());
        if (!mounted) return;
        setState(() => _previewBytes = bytes);
        await _uploadPoster(bytes, file.name);
      });
      return;
    }

    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final file = io.File(picked.path);
    final bytes = await file.readAsBytes();
    if (!mounted) return;
    setState(() => _previewBytes = bytes);
    await _uploadPoster(bytes, picked.name);
  }

  Future<void> _uploadPoster(Uint8List bytes, String fileName) async {
    if (!mounted) return;
    setState(() {
      _isUploadingPoster = true;
      _uploadProgress = 0.2;
    });
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConstant.uploadContentImg),
      );
      request.files.add(
        http.MultipartFile.fromBytes(
          'thumbnail',
          bytes,
          filename: fileName.isEmpty ? 'poster.jpg' : fileName,
        ),
      );
      _uploadProgress = 0.6;
      final response = await request.send();
      final body = await response.stream.bytesToString();
      final parsed = ContentImageUploadResponse.fromJson(jsonDecode(body));
      final uploaded = parsed.data?.thumbnailUrl ?? '';
      if (uploaded.trim().isNotEmpty) {
        _posterUrlCtrl.text = uploaded.trim();
      }
      if (!mounted) return;
      setState(() {
        _uploadProgress = 1;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Poster upload failed')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingPoster = false;
          _uploadProgress = 0;
        });
      }
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final initial = _releaseDate.isBefore(today) ? today : _releaseDate;
    final picked = await showDatePicker(
      context: context,
      firstDate: today,
      lastDate: DateTime(2100),
      initialDate: initial,
    );
    if (picked == null) return;
    setState(() => _releaseDate = picked);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(
      _releaseDate.year,
      _releaseDate.month,
      _releaseDate.day,
    );
    if (selected.isBefore(today)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Release date cannot be before current date'),
        ),
      );
      return;
    }
    final body = <String, dynamic>{
      "amount": _amountCtrl.text.trim(),
      "title": _titleCtrl.text.trim(),
      "description": _descCtrl.text.trim(),
      "posterUrl": _posterUrlCtrl.text.trim(),
      "releaseDate": _releaseDate.toIso8601String(),
      "seasonNumber": int.parse(_seasonNoCtrl.text.trim()),
      "castIds": [0],
    };
    Navigator.pop(context, body);
  }
}
