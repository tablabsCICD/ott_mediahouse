import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:media_house/app/ui/pages/help%20support%20page/helpDesk.dart';
import 'package:media_house/app/ui/pages/profile%20page/component/about_filmytell.dart';
import 'package:provider/provider.dart';

import 'package:media_house/app/config/routes/app_routes.dart';
import 'package:media_house/app/core/constant/app_constant.dart';
import 'package:media_house/app/provider/mediaHouseProvider.dart';
import 'package:media_house/app/provider/themeProvider.dart';
import 'package:media_house/app/ui/pages/profile%20page/component/EditProfilePage.dart';
import 'package:media_house/app/ui/pages/sign%20in%20page/SignInPage.dart';
import 'package:media_house/device/utils/ResponsiveWidget.dart';
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
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = context.watch<ThemeProvider>();

    return Consumer<MediaHouseProvider>(
      builder: (context, provider, _) {
        final mediaHouse = provider.mediaHouse;

        if (mediaHouse == null || isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final bool isApproved =
            (mediaHouse.status ?? 'PENDING').toUpperCase() == 'APPROVED';

        return Scaffold(
          body: SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  // ===================== HEADER =====================
                  Container(
                    width: ResponsiveWidget.isMobile(context)
                        ? double.infinity
                        : 500,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.primaryColor,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(70),
                        bottomRight: Radius.circular(70),
                      ),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundImage:
                                  NetworkImage(mediaHouse.logo ?? ""),
                            ),
                            if (isApproved)
                              Positioned(
                                bottom: 6,
                                right: 6,
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: theme.scaffoldBackgroundColor,
                                  ),
                                  child: const Icon(
                                    Icons.verified,
                                    color: Colors.blue,
                                    size: 18,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          mediaHouse.mediaHouseName ?? "",
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          mediaHouse.email ?? "",
                          style: const TextStyle(color: Colors.white70),
                        ),
                        Text(
                          mediaHouse.user?.mobileNumber ?? "",
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.scaffoldBackgroundColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const EditProfilePage(),
                              ),
                            );
                          },
                          child: Text(
                            "Edit Profile",
                            style: TextStyle(color: theme.canvasColor),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ===================== FEATURES =====================
                  _profileCard(
                    context,
                    title: "Feedback & Information",
                    children: [
                      ProfileOption(
                        icon: Icons.support_agent_sharp,
                        title: "Help",
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const HelpDeskPage()),
                        ),
                      ),
                      ProfileOption(
                        icon: Icons.file_copy,
                        title: "Terms, Policies and Liscenses",
                        onTap: () {},
                      ),
                      ProfileOption(
                        icon: Icons.info,
                        title: "About Filmytell",
                        onTap: () {
                          AboutFilmytellDialog.show(context);
                        },
                      ),
                      ProfileOption(
                        icon: Icons.star,
                        title: "Rate Us",
                        onTap: () {},
                      ),
                    ],
                  ),

                  // ===================== ACCOUNT =====================
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 0),
                    child: Card(
                      color: theme.cardColor,
                      child: ProfileOption(
                        icon: Icons.logout,
                        title: "Logout",
                        isDestructive: true,
                        onTap: () => _showLogoutDialog(context),
                      ),
                    ),
                  ),

                  const SizedBox(height: 200),

                  Text(
                    "Version · ${AppConstant.appVersion}",
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  const Text(
                    "© Filmytell - All Rights Reserved.",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ===================== LOGOUT DIALOG =====================
  void _showLogoutDialog(BuildContext context) {
    final parentContext = context;

    showCupertinoDialog(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          CupertinoDialogAction(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(dialogContext),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text("Logout"),
            onPressed: () async {
              Navigator.pop(dialogContext);
              await LocalSharePreferences().logOut();

              if (!parentContext.mounted) return;

              Navigator.pushReplacement(
                parentContext,
                MaterialPageRoute(builder: (_) => const SignInPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  // ===================== PROFILE CARD =====================
  Widget _profileCard(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);

    return Card(
      color: theme.cardColor,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 6),
                child: Text(
                  title,
                  style: TextStyle(
                    color: theme.canvasColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ...children,
          ],
        ),
      ),
    );
  }
}

// ===================== PROFILE OPTION =====================
class ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  const ProfileOption({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                //color: iconColor.withOpacity(0.12),
              ),
              child: Icon(icon, color: theme.primaryColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: isDestructive ? theme.primaryColor : theme.canvasColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}
