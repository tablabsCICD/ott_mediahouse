import 'package:flutter/material.dart';
import 'package:media_house/app/provider/themeProvider.dart';
import 'package:media_house/app/provider/user_provider.dart';
import 'package:media_house/app/widget/custom_textfield.dart';
import 'package:media_house/app/widget/show_toast.dart';
import 'package:media_house/device/utils/ResponsiveWidget.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/sharepreferences.dart';
import '../../../../provider/mediaHouseProvider.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getData();
    });
  }

  Future<void> getData() async {
    final localSharePreferences = LocalSharePreferences();
    final mediaHouse = await localSharePreferences.getMediaHouse();
    final user = await localSharePreferences.getUser();

    if (mediaHouse != null) {
      if (mounted) {
        await Provider.of<MediaHouseProvider>(context, listen: false)
            .fetchMediaHouseByUserId(user!.id!);
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<MediaHouseProvider>(context, listen: false);
      var result = await provider.updateMediaHouse();
      if (result['success'] == true) {
        print(result['message']);
        CustomToast.show("Profile updated successfully!", isSuccess: true);
        Navigator.of(context).pop();
      } else {
        print('Failure: ${result['message']}');
        CustomToast.show(result['message'].toString(), isSuccess: false);
      }
    } else {
      CustomToast.show("Fill All Data", isSuccess: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context);
    var selectedThemeData = themeProvider.getTheme;
    return Consumer<MediaHouseProvider>(builder: (context, provider, child) {
      final mediaHouse = provider.mediaHouse;

      if (mediaHouse == null) {
        return Center(
            child: CircularProgressIndicator(
                color: selectedThemeData.primaryColor));
      }

      return Scaffold(
        backgroundColor: selectedThemeData.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: selectedThemeData.primaryColor,
          title: Text(provider.mediaHouse.mediaHouseName ?? '-'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: SizedBox(
                width:
                    ResponsiveWidget.isMobile(context) ? double.infinity : 400,
                child: Column(
                  children: [
                    SizedBox(
                      height: 150,
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey.shade200,
                            backgroundImage: provider.profileImageProvider,
                            child: provider.profileImageProvider == null
                                ? const Icon(Icons.person,
                                    size: 40, color: Colors.grey)
                                : null,
                          ),

                          // Edit icon
                          InkWell(
                            onTap: () {
                              provider.pickImage("profile");
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    Colors.blue, // Background color of the icon
                              ),
                              padding: EdgeInsets.all(
                                  8.0), // Adjust padding as needed
                              child: Icon(
                                Icons.edit,
                                color: Colors.white, // Color of the icon
                                size: 20, // Adjust the size as needed
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    CustomTextField(
                      controller: provider.mediaHouseNameController,
                      label: 'Media House Name',
                      isName: true,
                      hintText: 'Enter a valid name',
                      isValidator: true,
                      textInputType: TextInputType.name,
                      //decoration: const InputDecoration(labelText: 'Name'),
                      //validator: (value) =>
                      //  value!.isEmpty ? 'Enter a valid name' : null,
                    ),
                    CustomTextField(
                      controller: provider.emailController,
                      label: 'Email',
                      isEmail: true,
                      isValidator: true,
                      hintText: 'Enter a valid Email',
                      textInputType: TextInputType.emailAddress,
                    ),
                    CustomTextField(
                      controller: provider.mobileController,
                      label: 'Contact Number',
                      isPhoneNumber: true,
                      isValidator: true,
                      hintText: 'Enter a valid Mobile Number',
                      textInputType: TextInputType.number,
                    ),
                    CustomTextField(
                      controller: provider.descriptionController,
                      label: 'Description',
                      isName: true,
                      hintText: 'Enter a valid name',
                      isValidator: true,
                      textInputType: TextInputType.text,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: ResponsiveWidget.isMobile(context)
                            ? double.infinity
                            : 400,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: selectedThemeData.primaryColor,
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6)),
                          ),
                          onPressed: _saveProfile,
                          child: Center(
                            child: Text(
                              "Save",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
