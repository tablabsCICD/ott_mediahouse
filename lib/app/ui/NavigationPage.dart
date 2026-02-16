import 'package:flutter/material.dart';
import 'package:media_house/app/core/constant/image_constant.dart';
import 'package:media_house/app/provider/themeProvider.dart';
import 'package:media_house/app/ui/pages/analytics_page/analyticsPage.dart';
import 'package:media_house/app/ui/pages/dashboard_page/dashboardpage.dart';
import 'package:media_house/app/ui/pages/document_page/documentpage.dart';
import 'package:media_house/app/ui/pages/released_content_page/released_content.dart';
import 'package:media_house/app/ui/pages/pendingContent_page/pendingcontent.dart';
import 'package:media_house/app/ui/pages/profile%20page/ProfilePage.dart';
import 'package:media_house/app/ui/pages/sereis/seriespage.dart';
import 'package:media_house/app/ui/pages/settlemet_page/SettlementPage.dart';
import 'package:media_house/app/ui/pages/shorts/shortspage.dart';
import 'package:media_house/app/ui/pages/uploadContent_page/select_upload_type.dart';
import 'package:media_house/app/ui/pages/uploadContent_page/upload_video.dart';
import 'package:media_house/device/utils/ResponsiveWidget.dart';
import 'package:provider/provider.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _NavigationPageState createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  final List<PageData> _pages = [
    PageData(title: 'Dashboard', page: DashboardPage()),
    PageData(title: 'Released Content', page: ReleasedContentPage()),
    PageData(title: 'All Content', page: PendingContentPage()),
    PageData(title: 'Shorts', page: ShortsPage()),
    PageData(title: 'Series', page: SeriesPage()),
    PageData(title: 'Analytics', page: AnalyticsPage()),
    PageData(title: 'Documents', page: DocumentsPage()),
    PageData(title: 'Settlement', page: SettlementPage()),
    PageData(title: 'Profile', page: ProfilePage()),
  ];

  final List<IconData> _icons = [
    Icons.dashboard_outlined,
    Icons.play_circle_outline_sharp,
    Icons.hourglass_top_outlined,
    Icons.play_circle_fill_sharp,
    Icons.play_circle_fill_sharp,
    Icons.bar_chart_sharp,
    Icons.document_scanner_outlined,
    Icons.transform_sharp,
    Icons.person,
  ];

  @override
  Widget build(BuildContext context) {
    var selectedThemeData =
        Provider.of<ThemeProvider>(context, listen: false).getTheme;

    return Scaffold(
      key: _scaffoldKey,
      appBar: ResponsiveWidget.isDesktop(context)
          ? null
          : AppBar(
              centerTitle: true,
              title: Text(
                _pages[_selectedIndex].title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: selectedThemeData.primaryColor,
              leading: IconButton(
                icon: const Icon(
                  Icons.menu,
                  color: Colors.white,
                ),
                onPressed: () {
                  _scaffoldKey.currentState!.openDrawer();
                },
              ),
              actions: [
                // IconButton(
                //   onPressed: () async {
                //     final localSharePreferences = LocalSharePreferences();
                //     await localSharePreferences.logOut();
                //     Navigator.pushReplacement(
                //       context,
                //       MaterialPageRoute(builder: (context) => SignInPage()),
                //     );
                //   },
                //   icon: Icon(
                //     Icons.logout,
                //     color: Colors.white,
                //   ),
                // ),
                IconButton(
                  highlightColor: selectedThemeData.primaryColor,
                  tooltip: "Upload Content",
                  onPressed: () {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => SelectUploadTypeDialog(),
                    );
                  },
                  icon: Icon(
                    Icons.file_upload_outlined,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _selectedIndex = 8;
                    });
                  },
                  icon: Icon(
                    Icons.account_circle_sharp,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
      drawer: ResponsiveWidget.isDesktop(context)
          ? null
          : Drawer(child: _buildDrawerContent(context)),
      body: Row(
        children: [
          if (ResponsiveWidget.isDesktop(context))
            Container(
              width: 250,
              color: selectedThemeData.cardColor,
              child: _buildDrawerContent(context),
            ),
          Expanded(child: _pages[_selectedIndex].page),
        ],
      ),
    );
  }

  Widget _buildDrawerContent(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context, listen: true);
    var selectedThemeData = themeProvider.getTheme;
    bool isDark = selectedThemeData.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DrawerHeader(
          decoration: BoxDecoration(
            color: selectedThemeData.primaryColor,
          ),
          child: Hero(
            tag: "logo",
            child: ClipRRect(
              borderRadius: BorderRadiusGeometry.circular(25),
              child: Image.asset(
                ImageConstant.logo2,
              ),
            ),
          ),
        ),
        Row(
          children: [
            // ResponsiveWidget.isDesktop(context)
            //     ? IconButton(
            //         tooltip: "Notifications",
            //         onPressed: () {},
            //         icon: Icon(
            //           Icons.notifications_on_sharp,
            //           color: selectedThemeData.canvasColor,
            //         ),
            //       )
            //     : Text(''),
            Expanded(
              child: Divider(
                color: selectedThemeData.primaryColor,
                thickness: 1,
              ),
            ),
            IconButton(
              tooltip: "Theme",
              icon: Icon(
                isDark ? Icons.wb_sunny_outlined : Icons.nightlight_round,
                color: selectedThemeData.canvasColor,
              ),
              onPressed: () {
                themeProvider.toggleTheme(); // Toggle the theme
              },
            ),
          ],
        ),
        SizedBox(
          height: ResponsiveWidget.isDesktop(context) ? 0 : 1,
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: Icon(
                  _icons[index],
                  color: _selectedIndex == index
                      ? selectedThemeData.primaryColor
                      : selectedThemeData.canvasColor,
                ),
                title: Text(
                  _pages[index].title,
                  style: TextStyle(
                    color: _selectedIndex == index
                        ? selectedThemeData.primaryColor
                        : selectedThemeData.canvasColor,
                  ),
                ),
                selected: _selectedIndex == index,
                onTap: () {
                  setState(() {
                    _selectedIndex = index;
                    if (!ResponsiveWidget.isDesktop(context)) {
                      Navigator.pop(context); //Close drawer on mobile/tablet
                    }
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class PageData {
  final String title;
  final Widget page;

  const PageData({required this.title, required this.page});
}
