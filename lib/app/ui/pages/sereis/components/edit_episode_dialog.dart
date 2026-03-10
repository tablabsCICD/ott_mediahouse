import 'package:flutter/material.dart';
import 'package:media_house/data/models/response/series_detail_response.dart';
import 'package:provider/provider.dart';

import '../../../../provider/themeProvider.dart';

class EditEpisodeDialog extends StatefulWidget {
  final Episode episode;

  const EditEpisodeDialog({
    super.key,
    required this.episode,
  });

  @override
  State<EditEpisodeDialog> createState() => _EditEpisodeDialogState();
}

class _EditEpisodeDialogState extends State<EditEpisodeDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _amountCtrl;
  late final TextEditingController _episodeNoCtrl;
  late final TextEditingController _runtimeCtrl;
  late final TextEditingController _posterUrlCtrl;
  late final TextEditingController _videoUrlCtrl;
  bool _isFree = false;

  @override
  void initState() {
    super.initState();
    final ep = widget.episode;
    _titleCtrl = TextEditingController(text: ep.title ?? '');
    _descCtrl = TextEditingController(text: ep.description ?? '');
    _amountCtrl = TextEditingController(text: '${ep.amount ?? 0}');
    _episodeNoCtrl = TextEditingController(text: '${ep.episodeNumber ?? 1}');
    _runtimeCtrl = TextEditingController(text: '${ep.runtime ?? 0}');
    _posterUrlCtrl = TextEditingController(text: ep.posterUrl ?? '');
    _videoUrlCtrl = TextEditingController(text: ep.videoUrl ?? '');
    _isFree = ep.free ?? false;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _amountCtrl.dispose();
    _episodeNoCtrl.dispose();
    _runtimeCtrl.dispose();
    _posterUrlCtrl.dispose();
    _videoUrlCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context, listen: false).getTheme;
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 520,
        constraints: const BoxConstraints(maxWidth: 520),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Edit Episode',
                        style: TextStyle(
                          color: theme.primaryColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close, color: theme.canvasColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  _section(theme, 'Basic Details', [
                    _field(
                      _titleCtrl,
                      'Title',
                      validator: (v) {
                        final t = (v ?? '').trim();
                        if (t.isEmpty) return 'Title is required';
                        if (t.length < 2) return 'Enter valid title';
                        return null;
                      },
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    _field(
                      _descCtrl,
                      'Description',
                      maxLines: 3,
                      validator: (v) {
                        final t = (v ?? '').trim();
                        if (t.isEmpty) return 'Description is required';
                        if (t.length < 5) return 'Description is too short';
                        return null;
                      },
                    ),
                  ]),
                  const SizedBox(height: 10),
                  _section(theme, 'Pricing & Runtime', [
                    _field(
                      _amountCtrl,
                      'Episode Amount',
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        final n = num.tryParse((v ?? '').trim());
                        if (n == null) return 'Enter valid amount';
                        if (n < 0) return 'Amount cannot be negative';
                        return null;
                      },
                    ),
                    /*    _field(
                      _episodeNoCtrl,
                      'Episode Number',
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        final n = int.tryParse((v ?? '').trim());
                        if (n == null) return 'Enter valid episode number';
                        if (n <= 0) return 'Episode number must be > 0';
                        return null;
                      },
                    ),
                    _field(
                      _runtimeCtrl,
                      'Runtime (min)',
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        final n = int.tryParse((v ?? '').trim());
                        if (n == null) return 'Enter valid runtime';
                        if (n < 0) return 'Runtime cannot be negative';
                        return null;
                      },
                    ),
                    */
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Free Preview',
                        style: TextStyle(color: theme.canvasColor),
                      ),
                      value: _isFree,
                      onChanged: (value) => setState(() => _isFree = value),
                    ),
                  ]),
                  /*  const SizedBox(height: 10),
                  _section(theme, 'Media URLs', [
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
                    _field(
                      _videoUrlCtrl,
                      'Video URL',
                      validator: (v) {
                        if ((v ?? '').trim().isEmpty) {
                          return 'Video URL is required';
                        }
                        return null;
                      },
                    ),
                  ]),
                   */
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
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
                          ),
                          child: const Text('Save'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _section(ThemeData theme, String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: theme.primaryColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          ...children
              .map((w) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: w,
                  ))
              .toList(growable: false),
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    final theme = Provider.of<ThemeProvider>(context, listen: false).getTheme;
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
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

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleCtrl.text.trim();
    final body = <String, dynamic>{
      "amount": _amountCtrl.text.trim(),
      "title": title,
      "description": _descCtrl.text.trim(),
      "episodeNumber": int.parse(_episodeNoCtrl.text.trim()),
      "partName": title,
      "free": _isFree,
      "posterUrl": _posterUrlCtrl.text.trim(),
      "videoUrl": _videoUrlCtrl.text.trim(),
      "releaseDate": DateTime.now().toIso8601String(),
      "runtime": int.parse(_runtimeCtrl.text.trim()),
    };

    Navigator.pop(context, body);
  }
}
