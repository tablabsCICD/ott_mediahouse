/*
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:media_house/app/widget/custom_textfield.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';

import '../../../../device/utils/ResponsiveWidget.dart';
import '../../../provider/ticketProvider.dart';

class HelpSupportPage extends StatefulWidget {
  const HelpSupportPage({super.key});

  @override
  _HelpSupportPageState createState() => _HelpSupportPageState();
}

class _HelpSupportPageState extends State<HelpSupportPage> {

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    await Provider.of<TicketProvider>(context, listen: false)
        .getRaisedTicketByUserId();
  }


  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Help & Support',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: theme.primaryColor,
      ),
      body: Consumer<TicketProvider>(
        builder: (context, provider, child) => Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: SizedBox(
              width: ResponsiveWidget.isMobile(context) ? double.infinity : 500,
              child: Column(
                children: [
                  CustomTextField(
                    controller: provider.topicController,
                    hintText: 'Enter your query',
                    textInputType: TextInputType.multiline,
                    maxLine: 5,
                  ),
                  SizedBox(height: 10),
                  provider.uploadedImageUrl == null ||
                          provider.uploadedImageUrl == ''
                      ? GestureDetector(
                          onTap: () {
                            provider.pickImage();
                          },
                          child: Container(
                            height: 40,
                            width: 120,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: theme.primaryColor,
                              ),
                              borderRadius: BorderRadius.circular(
                                15,
                              ),
                            ),
                            child: Center(child: Text('Attach Image')),
                          ),
                        )
                      : Column(
                          children: [
                            Container(
                              width: 100, // Set your desired width
                              height: 100, // Set your desired height
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                // Rounded corners (optional)
                                image: DecorationImage(
                                  image: NetworkImage(
                                      provider.uploadedImageUrl ?? ""),
                                  fit: BoxFit.cover, // Adjust the image fit
                                ),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: provider.removeImage,
                              icon: Icon(
                                Icons.delete,
                                color: theme.primaryColor,
                              ),
                              label: Text(
                                'Remove',
                                style: TextStyle(
                                  color: theme.primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: provider.raiseTicket,
                    child: Text('Submit'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      foregroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      textStyle:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: provider.ticketList.length,
                      itemBuilder: (context, index) {
                        final query = provider.ticketList[index];
                        DateTime date = DateTime.fromMillisecondsSinceEpoch(
                            provider.ticketList[index].date!);
                        String formattedDate =
                            DateFormat('yyyy-MM-dd HH:mm:ss').format(date);

                        return Stack(
                          children: [
                            Card(
                              color: theme.cardColor,
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              child: ListTile(
                                leading: query.image != null
                                    ? CircleAvatar(
                                        radius: 50,
                                        backgroundImage:
                                            NetworkImage(query.image ?? ""),
                                      )
                                    : Icon(Icons.help_outline,
                                        color: theme.primaryColor),
                                title: Text(query.topic ?? '',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(query.feedback ?? '',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14)),
                                    Text(
                                      formattedDate,
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 1,
                              right: 1,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.check_circle_outline_outlined,
                                    color: Colors.grey[600],
                                    size: 18,
                                  ),
                                  SizedBox(width: 2),
                                  Text(
                                    'sent',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 13,
                                    ),
                                  ),
                                  // SizedBox(
                                  //   width: 1,
                                  // ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete,
                                      color: theme.primaryColor,
                                      size: 18,
                                    ),
                                    onPressed: () => null,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
*/
