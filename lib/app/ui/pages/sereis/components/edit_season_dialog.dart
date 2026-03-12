import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:media_house/data/models/response/series_detail_response.dart';
import 'package:provider/provider.dart';
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

  late final TextEditingController _amountCtrl;

  @override
  void initState() {
    super.initState();
    final s = widget.season;
    _amountCtrl = TextEditingController(text: '${s.amount ?? 0}');
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
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
                          title: 'Season Pricing',
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: theme.scaffoldBackgroundColor
                                    .withValues(alpha: 0.35),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color:
                                      theme.dividerColor.withValues(alpha: 0.35),
                                ),
                              ),
                              child: Text(
                                'Only the season price can be edited here. For title, description, poster, release date, or any other season change, please raise a ticket to the admin.',
                                style: TextStyle(
                                  color:
                                      theme.canvasColor.withValues(alpha: 0.82),
                                  height: 1.45,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            _field(
                              _amountCtrl,
                              'Season Price',
                              keyboardType: TextInputType.number,
                              validator: (v) {
                                final n = num.tryParse((v ?? '').trim());
                                if (n == null) return 'Enter valid amount';
                                if (n < 0) return 'Amount cannot be negative';
                                return null;
                              },
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

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final releaseDateValue = widget.season.releaseDate != null &&
            widget.season.releaseDate! > 0
        ? DateTime.fromMillisecondsSinceEpoch(widget.season.releaseDate!)
            .toIso8601String()
        : null;
    final body = <String, dynamic>{
      "amount": _amountCtrl.text.trim(),
      "title": widget.season.title ?? '',
      "description": widget.season.description ?? '',
      "posterUrl": widget.season.posterUrl ?? '',
      "releaseDate": releaseDateValue,
      "seasonNumber": widget.season.seasonNumber ?? 1,
      "castIds": [0],
      "active": widget.season.active ?? false,
    };
    Navigator.pop(context, body);
  }
}
