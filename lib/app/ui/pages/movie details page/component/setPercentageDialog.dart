import 'package:flutter/material.dart';
import 'package:media_house/app/provider/videoProvider.dart';
import 'package:provider/provider.dart';

import '../../../../../domain/entities/content.dart';
import '../../../../provider/themeProvider.dart';

class SetPercentageDialog extends StatefulWidget {
  Content content;

  SetPercentageDialog({
    super.key,
    required this.content,
  });

  @override
  _SetPercentageDialogState createState() => _SetPercentageDialogState();
}

class _SetPercentageDialogState extends State<SetPercentageDialog> {
  int _percentage = 50;
  final TextEditingController _textController = TextEditingController(text: "50");

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // Safely parse the percentage
    _percentage = int.tryParse(widget.content.mediaHouseIncentivePecentage?.toString() ?? '') ?? 50;

    // Sync the value to the text controller
    _textController.text = _percentage.toString();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final videoProvider = Provider.of<VideoProvider>(context);
    final selectedThemeData = themeProvider.getTheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              "Select Percentage Split",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Slider
            Slider(
              activeColor: selectedThemeData.primaryColor,
              value: _percentage.toDouble(),
              min: 0,
              max: 100,
              divisions: 100,
              label: "$_percentage%",
              onChanged: (value) {
                setState(() {
                  _percentage = value.toInt(); // Convert to int
                  _textController.text = _percentage.toString(); // Sync with text field
                });
              },
            ),

            const SizedBox(height: 10),

            // Media House and Platform percentage display
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Media House: $_percentage%"),
                Text("Platform: ${100 - _percentage}%"),
              ],
            ),

            const SizedBox(height: 20),

            // TextField to input percentage manually
            SizedBox(
              width: 150,
              child: TextField(
                controller: _textController,
                cursorColor: selectedThemeData.primaryColor,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Media House %",
                  labelStyle: TextStyle(
                    color: selectedThemeData.canvasColor,
                  ),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: selectedThemeData.cardColor,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(
                      color: selectedThemeData.primaryColor,
                      width: 2,
                    ),
                  ),
                ),
                onChanged: (value) {
                  int? newValue = int.tryParse(value);
                  if (newValue != null && newValue >= 0 && newValue <= 100) {
                    setState(() {
                      _percentage = newValue;
                    });
                  } else if (value.isEmpty) {
                    setState(() {
                      _percentage = 0; // Default to 0 if input is cleared
                    });
                  }
                },
              ),
            ),

            const SizedBox(height: 20),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedThemeData.primaryColor,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedThemeData.primaryColor,
                  ),
                  onPressed: () async {
                    await videoProvider.setMoviePercentage(
                      context,
                      widget.content,
                      _percentage,
                      100 - _percentage,
                    );
                    Navigator.pop(context, _percentage);
                  },
                  child: const Text("Set"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
