import 'package:flutter/material.dart';
import 'package:media_house/app/provider/videoProvider.dart';
import 'package:provider/provider.dart';


class MultiSelectDialog extends StatefulWidget {
  final String label;
  final List<String> items;
  final ThemeData theme;

  const MultiSelectDialog({
    Key? key,
    required this.label,
    required this.items,
    required this.theme,
  }) : super(key: key);

  @override
  State<MultiSelectDialog> createState() => _MultiSelectDialogState();
}

class _MultiSelectDialogState extends State<MultiSelectDialog> {
  List<String> _selectedItems = [];

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
    } else if (widget.label == "Languages") {
      _selectedItems = List.from(provider.selectedLanguages);
    }
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
    if (widget.label == "Genres") {
      provider.setSelectedGeners(_selectedItems);
    } else if (widget.label == "Audio Formats") {
      provider.setSelectedAudioFormat(_selectedItems);
    } else if (widget.label == "Subtitle Languages") {
      provider.setSelectedSubLanguages(_selectedItems);
    } else if (widget.label == "Languages") {
      provider.setSelectedLanguages(_selectedItems);
    }
    Navigator.pop(context);
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
          children: widget.items
              .map((item) => CheckboxListTile(
            value: _selectedItems.contains(item),
            title: Text(
              item,
              style: TextStyle(color: widget.theme.canvasColor),
            ),
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: (isChecked) => _itemChange(item, isChecked!),
            activeColor: widget.theme.primaryColor,
            checkColor: Colors.white,
          ))
              .toList(),
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
