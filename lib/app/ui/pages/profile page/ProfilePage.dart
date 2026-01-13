import 'package:flutter/material.dart';
import 'package:media_house/app/config/routes/app_routes.dart';
import 'package:media_house/app/provider/mediaHouseProvider.dart';
import 'package:media_house/app/provider/themeProvider.dart';
import 'package:media_house/app/provider/user_provider.dart';
import 'package:media_house/app/ui/pages/help%20support%20page/HelpSupportPage.dart';
import 'package:media_house/app/ui/pages/notification%20page/NotificationPage.dart';
import 'package:media_house/app/ui/pages/profile%20page/component/EditProfilePage.dart';
import 'package:media_house/app/ui/pages/sign%20in%20page/SignInPage.dart';
import 'package:media_house/device/utils/ResponsiveWidget.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constant/prefrense_constant.dart';
import '../../../core/utils/sharepreferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var themeProvider = Provider.of<ThemeProvider>(context, listen: true);
    var selectedThemeData = themeProvider.getTheme;
    bool isDark = selectedThemeData.brightness == Brightness.dark;

    return  Consumer<MediaHouseProvider>(
        builder: (context, provider, child) {
      final mediaHouse = provider.mediaHouse;

      if (mediaHouse == null) {
        return const Center(child: CircularProgressIndicator());
      }

      return  Scaffold(
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                Container(
                  width: ResponsiveWidget.isMobile(context)
                      ? double.infinity
                      : 400, //double.infinity,
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: theme.primaryColor,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(70),
                      bottomRight: Radius.circular(70),
                    ),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(provider.mediaHouse.logo??""),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        provider.mediaHouse.mediaHouseName??"",
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        provider.mediaHouse.email??'',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                      Text(
                        provider.mediaHouse.user!.mobileNumber??"",
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EditProfilePage(),
                            ),
                          );
                        },
                        child: Text(
                          "Edit Profile",
                          style: TextStyle(
                            color: selectedThemeData.canvasColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ProfileOption(
                  icon: Icons.support_agent_sharp,
                  title: "Help",
                  onTap: () => Navigator.pushNamed(
                    context,
                   AppRoutes.helpSupport
                  ),
                ),
            /*    ProfileOption(
                  icon: Icons.notifications,
                  title: "Notifications",
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const NotificationPage()),
                  ),
                ),*/
                ProfileOption(
                  icon: Icons.logout,
                  title: "Logout",
                  onTap: () async {
                    final localSharePreferences = LocalSharePreferences();
                  await localSharePreferences.logOut();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => SignInPage()),
                    );
                  },
                ),
                const SizedBox(height: 350),
                Text(
                  'Referred by: ${provider.mediaHouse.user!.refferedBy}',
                  style: const TextStyle(color: Colors.grey),
                )
              ],
            ),
          ),
        ),
      );}
    );
  }
}

///////////////////////////// Profile Option Widget /////////////////////////////
class ProfileOption extends StatefulWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final double? balance;

  const ProfileOption({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.balance,
  });

  @override
  State<ProfileOption> createState() => _ProfileOptionState();
}

class _ProfileOptionState extends State<ProfileOption> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: ResponsiveWidget.isMobile(context) ? double.infinity : 600,
      child: ListTile(
        leading: Icon(widget.icon, color: Theme.of(context).primaryColor),
        title:
            Text(widget.title, style: Theme.of(context).textTheme.titleMedium),
        subtitle: widget.balance != null ? Text('₹ ${widget.balance}') : null,
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: widget.onTap,
      ),
    );
  }
}
