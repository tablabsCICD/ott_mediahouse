import 'package:flutter/material.dart';
import 'package:media_house/app/provider/videoProvider.dart';
import 'package:provider/provider.dart';

class MultiSelectDialog extends StatefulWidget {
  final String label;
  final List<String> items;
  final Map<String, List<String>> groupedItems;
  final ThemeData theme;

  const MultiSelectDialog({
    Key? key,
    required this.label,
    required this.items,
    this.groupedItems = const {},
    required this.theme,
  }) : super(key: key);

  @override
  State<MultiSelectDialog> createState() => _MultiSelectDialogState();
}

class _MultiSelectDialogState extends State<MultiSelectDialog> {
  List<String> _selectedItems = [];
  final TextEditingController _otherLanguageController =
      TextEditingController();

  bool get _supportsOtherLanguage =>
      widget.label == "Languages" || widget.label == "Audio Languages";

  @override
  void initState() {
    super.initState();
    // Initialize selected items based on current provider state
    final provider = Provider.of<VideoProvider>(context, listen: false);
    if (widget.label == "Genres") {
      _selectedItems = List.from(provider.selectedGeners);
    } else if (widget.label == "Audio Formats") {
      _selectedItems = List.from(provider.selectedAudioFormat);
    } else if (widget.label == "Subtitle Languages") {
      _selectedItems = List.from(provider.selectedSubLanguages);
    } else if (widget.label == "Languages" ||
        widget.label == "Audio Languages") {
      _selectedItems = provider.selectedLanguages
          .map((language) => language.language ?? "")
          .where((language) => language.isNotEmpty)
          .toList();
      final customLanguages =
          _selectedItems.where((item) => !widget.items.contains(item)).toList();
      _otherLanguageController.text = customLanguages.join(', ');
    }
  }

  @override
  void dispose() {
    _otherLanguageController.dispose();
    super.dispose();
  }

  void _itemChange(String itemValue, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedItems.add(itemValue);
      } else {
        _selectedItems.remove(itemValue);
      }
    });
  }

  void _cancel() {
    Navigator.pop(context);
  }

  void _submit() {
    final provider = Provider.of<VideoProvider>(context, listen: false);
    final submittedItems = _supportsOtherLanguage
        ? _selectedItems.where((item) => widget.items.contains(item)).toList()
        : List<String>.from(_selectedItems);
    if (_supportsOtherLanguage) {
      final customLanguages = _otherLanguageController.text
          .split(',')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty);
      for (final language in customLanguages) {
        if (!submittedItems.contains(language)) {
          submittedItems.add(language);
        }
      }
    }

    if (widget.label == "Genres") {
      provider.setSelectedGeners(submittedItems);
    } else if (widget.label == "Audio Formats") {
      provider.setSelectedAudioFormat(submittedItems);
    } else if (widget.label == "Subtitle Languages") {
      provider.setSelectedSubLanguages(submittedItems);
    } else if (widget.label == "Languages" ||
        widget.label == "Audio Languages") {
      provider.setSelectedLanguages(submittedItems);
    }
    Navigator.pop(context);
  }

  List<Widget> _buildLanguageOptions() {
    final groupedItems = widget.groupedItems;
    if (groupedItems.isEmpty) {
      return widget.items.map(_buildCheckbox).toList();
    }

    return groupedItems.entries.expand((entry) {
      return [
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 4),
          child: Text(
            entry.key,
            style: TextStyle(
              color: widget.theme.primaryColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        ...entry.value.map(_buildCheckbox),
      ];
    }).toList();
  }

  Widget _buildCheckbox(String item) {
    return CheckboxListTile(
      value: _selectedItems.contains(item),
      title: Text(
        item,
        style: TextStyle(color: widget.theme.canvasColor),
      ),
      controlAffinity: ListTileControlAffinity.leading,
      onChanged: (isChecked) => _itemChange(item, isChecked!),
      activeColor: widget.theme.primaryColor,
      checkColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: widget.theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Text(
        'Select ${widget.label}',
        style: TextStyle(
          color: widget.theme.primaryColor,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SingleChildScrollView(
        child: ListBody(
          children: [
            ..._buildLanguageOptions(),
            if (_supportsOtherLanguage) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _otherLanguageController,
                style: TextStyle(color: widget.theme.canvasColor),
                decoration: InputDecoration(
                  labelText: 'Other language',
                  hintText: 'Enter language name',
                  labelStyle: TextStyle(color: widget.theme.canvasColor),
                  hintStyle: TextStyle(
                    color: widget.theme.canvasColor.withOpacity(0.6),
                  ),
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _cancel,
          child: Text(
            'Cancel',
            style: TextStyle(color: widget.theme.canvasColor.withOpacity(0.7)),
          ),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.theme.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Submit',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
