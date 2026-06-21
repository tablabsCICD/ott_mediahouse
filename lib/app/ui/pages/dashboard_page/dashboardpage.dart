import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:media_house/app/provider/mediaHouseProvider.dart';
import 'package:media_house/app/provider/themeProvider.dart';
import 'package:media_house/app/provider/user_provider.dart';
import 'package:media_house/app/ui/pages/dashboard_page/components/settlementCards.dart';
import 'package:media_house/app/ui/pages/dashboard_page/components/buildSummaryCard.dart';
import 'package:media_house/app/ui/pages/dashboard_page/components/contentUploadCrad.dart';
import 'package:media_house/app/ui/pages/profile%20page/ProfilePage.dart';
import 'package:media_house/app/ui/pages/uploadContent_page/select_upload_type.dart';
import 'package:media_house/app/widget/CustomLineGraph.dart';
import 'package:media_house/app/widget/TopMoviesLineGraph.dart';
import 'package:media_house/app/widget/show_toast.dart';
import 'package:media_house/device/utils/ResponsiveWidget.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/sharepreferences.dart';

class DashboardPage extends StatefulWidget {
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getData();
    });
  }

  Future<void> getData() async {
    final mediaHouseProvider =
        Provider.of<MediaHouseProvider>(context, listen: false);
    final localSharePreferences = LocalSharePreferences();
    final user = await localSharePreferences.getUser();
    print(user!.firstName! + ':::::::::UserName:::::::');
    final mediaHouse = await localSharePreferences.getMediaHouse();
    print(mediaHouse!.mediaHouseName! + ':::::::::MediaHouse:::::::');
    if (mounted) {
      await Provider.of<UserProvider>(context, listen: false)
          .getUserById(user.id!);
      await Provider.of<UserProvider>(context, listen: false)
          .fetchMediaHouseByUserId(user.id!, context);
    }
    await mediaHouseProvider.fetchMediaHouseByUserId(user.id!);
    await mediaHouseProvider
        .fetchMediaHouseDashboardData(mediaHouseProvider.mediaHouse.id!);
  }

  @override
  Widget build(BuildContext context) {
    var selectedThemeData =
        Provider.of<ThemeProvider>(context, listen: true).getTheme;
    Provider.of<UserProvider>(context);

    return Consumer<MediaHouseProvider>(builder: (context, provider, child) {
      final screen = MediaQuery.of(context).size;
      final mobileGraphHeight =
          math.min(620.0, math.max(460.0, screen.height * 0.68));
      return Scaffold(
        backgroundColor: selectedThemeData.scaffoldBackgroundColor,
        body: ResponsiveWidget.isMobile(context) ////mobile view////
            ? SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        //tileColor: selectedThemeData.cardColor,
                        onTap: () {
                          ProfilePage();
                        },
                        leading: Stack(
                          alignment: AlignmentGeometry.center,
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundImage:
                                  NetworkImage(provider.mediaHouse.logo ?? ""),
                            ),
                            (provider.mediaHouse.status ?? 'PENDING')
                                        .toUpperCase() ==
                                    'APPROVED'
                                ? Positioned(
                                    bottom: 2,
                                    right: 2,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: selectedThemeData
                                            .scaffoldBackgroundColor,
                                      ),
                                      child: Icon(
                                        Icons.verified,
                                        color: Colors.blue,
                                        size: 14,
                                      ),
                                    ),
                                  )
                                : SizedBox(),
                          ],
                        ),
                        title: Text(
                          provider.mediaHouse.mediaHouseName ?? 'NA',
                          style: TextStyle(
                            color: selectedThemeData.primaryColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(provider.mediaHouse.email ?? ""),
                        trailing: _buildActionButton(
                            selectedThemeData,
                            Icons.file_upload_outlined,
                            "Upload Content",
                            context,
                            provider),
                      ),
                      SizedBox(height: 10),
                      GridView.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 1.35,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        children: [
                          BuildSummaryCard(
                            icon: Icons.currency_rupee_sharp,
                            title: "Revenue",
                            value:
                                "${provider.mediaHouseDashboardData.viewRevenue ?? 0.0}",
                            onTap: () {
                              _showGraphDialog(
                                theme: selectedThemeData,
                                title: 'Revenue Graph',
                                yAxisLabel: 'sales',
                                graphNumber: 0,
                                metrics: const ["revenue"],
                              );
                            },
                          ),
                          BuildSummaryCard(
                            icon: Icons.visibility_outlined,
                            title: "Views",
                            value:
                                "${provider.mediaHouseDashboardData.totalViews ?? 0}",
                            onTap: () {
                              _showGraphDialog(
                                theme: selectedThemeData,
                                title: 'Views Graph',
                                yAxisLabel: 'views',
                                graphNumber: 1,
                                metrics: const ["views"],
                              );
                            },
                          ),
                          BuildSummaryCard(
                            icon: Icons.play_circle_outline_sharp,
                            title: "Released Content",
                            value:
                                "${provider.mediaHouseDashboardData.approvedContent ?? 0}",
                            onTap: () {
                              _showGraphDialog(
                                theme: selectedThemeData,
                                title: 'Released Content',
                                yAxisLabel: 'Released',
                                graphNumber: 2,
                                metrics: const ["Released"],
                              );
                            },
                          ),
                          BuildSummaryCard(
                            icon: Icons.hourglass_top_outlined,
                            title: "Pending Content",
                            value:
                                "${provider.mediaHouseDashboardData.pendingContentCount ?? 0}",
                            onTap: () {},
                          ),
                          BuildSummaryCard(
                            icon: Icons.schedule,
                            title: "Upcoming Content",
                            value:
                                "${provider.mediaHouseDashboardData.upcomingContentCount ?? 0}",
                            onTap: () {},
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      SizedBox(
                        height: mobileGraphHeight,
                        child: Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          color: selectedThemeData.cardColor,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: selectedThemeData.dividerColor
                                    .withValues(alpha: 0.22),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: TopMoviesLineGraph(
                                isRevenue: true,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      SettlementCard(),
                      SizedBox(
                        height: 500,
                      )
                    ],
                  ),
                ),
              )
            : SingleChildScrollView(
                child: Padding(
                  ////desktop view////
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        //tileColor: selectedThemeData.cardColor,
                        leading: Stack(
                          alignment: AlignmentGeometry.center,
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundImage:
                                  NetworkImage(provider.mediaHouse.logo ?? ""),
                            ),
                            (provider.mediaHouse.status ?? 'PENDING')
                                        .toUpperCase() ==
                                    'APPROVED'
                                ? Positioned(
                                    bottom: 3,
                                    right: 3,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: selectedThemeData
                                            .scaffoldBackgroundColor,
                                      ),
                                      child: Icon(
                                        Icons.verified,
                                        color: Colors.blue,
                                        size: 14,
                                      ),
                                    ),
                                  )
                                : SizedBox(),
                          ],
                        ),
                        title: Text(
                          provider.mediaHouse.mediaHouseName ?? 'NA',
                          style: TextStyle(
                            color: selectedThemeData.primaryColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(provider.mediaHouse.email ?? ""),
                        trailing: _buildActionButton(
                            selectedThemeData,
                            Icons.file_upload_outlined,
                            "Upload Content",
                            context,
                            provider),
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  BuildSummaryCard(
                                    icon: Icons.currency_rupee_sharp,
                                    title: "Revenue",
                                    value:
                                        "${provider.mediaHouseDashboardData.viewRevenue ?? 0.0}",
                                    onTap: () {
                                      _showGraphDialog(
                                        theme: selectedThemeData,
                                        title: 'Revenue Graph',
                                        yAxisLabel: 'sales',
                                        graphNumber: 0,
                                        metrics: const ["revenue"],
                                      );
                                    },
                                  ),
                                  SizedBox(width: 10),
                                  BuildSummaryCard(
                                    icon: Icons.visibility_outlined,
                                    title: "Views",
                                    value:
                                        "${provider.mediaHouseDashboardData.totalViews ?? 0}",
                                    onTap: () {
                                      _showGraphDialog(
                                        theme: selectedThemeData,
                                        title: 'Views Graph',
                                        yAxisLabel: 'views',
                                        graphNumber: 1,
                                        metrics: const ["views"],
                                      );
                                    },
                                  ),
                                  SizedBox(width: 10),
                                  BuildSummaryCard(
                                    icon: Icons.play_circle_outline_sharp,
                                    title: "Released Content",
                                    value:
                                        "${provider.mediaHouseDashboardData.approvedContent ?? 0}",
                                    onTap: () {
                                      _showGraphDialog(
                                        theme: selectedThemeData,
                                        title: 'Released Content',
                                        yAxisLabel: 'Released',
                                        graphNumber: 2,
                                        metrics: const ["Released"],
                                      );
                                    },
                                  ),
                                  SizedBox(width: 10),
                                  BuildSummaryCard(
                                    icon: Icons.hourglass_top_outlined,
                                    title: "Pending Content",
                                    value:
                                        "${provider.mediaHouseDashboardData.pendingContentCount ?? 0}",
                                    onTap: () {},
                                  ),
                                  SizedBox(width: 10),
                                  BuildSummaryCard(
                                    icon: Icons.schedule,
                                    title: "Upcoming Content",
                                    value:
                                        "${provider.mediaHouseDashboardData.upcomingContentCount ?? 0}",
                                    onTap: () {},
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isCompactDesktop = constraints.maxWidth < 1200;
                          final graphCard = Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            color: selectedThemeData.cardColor,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: selectedThemeData.dividerColor
                                      .withValues(alpha: 0.22),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: TopMoviesLineGraph(
                                  isRevenue: true,
                                ),
                              ),
                            ),
                          );

                          if (isCompactDesktop) {
                            return Column(
                              children: [
                                SizedBox(
                                  height: 280,
                                  child: ContentUploadCard(provider.mediaHouse),
                                ),
                                const SizedBox(height: 10),
                                SizedBox(height: 460, child: graphCard),
                              ],
                            );
                          }

                          return SizedBox(
                            height: 430,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: ContentUploadCard(provider.mediaHouse),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  flex: 3,
                                  child: graphCard,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      SettlementCard()
                    ],
                  ),
                ),
              ),
      );
    });
  }

  void _showGraphDialog({
    required ThemeData theme,
    required String title,
    required String yAxisLabel,
    required int graphNumber,
    required List<String> metrics,
  }) {
    final size = MediaQuery.of(context).size;
    final dialogWidth = math.min(size.width * 0.95, 1100.0);
    final dialogHeight = math.min(size.height * 0.9, 760.0);

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: theme.cardColor,
          insetPadding: EdgeInsets.symmetric(
            horizontal: ResponsiveWidget.isMobile(context) ? 10 : 24,
            vertical: ResponsiveWidget.isMobile(context) ? 16 : 24,
          ),
          child: SizedBox(
            width: dialogWidth,
            height: dialogHeight,
            child: CustomLineGraph(
              title: title,
              yAxisLabel: yAxisLabel,
              canPop: true,
              graphNumber: graphNumber,
              metrics: metrics,
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton(ThemeData theme, IconData icon, String tooltip,
      BuildContext context, MediaHouseProvider provider) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.cardColor,
      ),
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: IconButton(
          highlightColor: theme.primaryColor,
          tooltip: tooltip,
          onPressed: () {
            (provider.mediaHouse.status ?? 'PENDING').toUpperCase() ==
                    "APPROVED"
                ? showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => SelectUploadTypeDialog(),
                  )
                : CustomToast.show(
                    context, "First you need to get approval from admin",
                    isSuccess: false);
          },
          icon: Icon(
            icon,
            color: theme.canvasColor,
          ),
        ),
      ),
    );
  }
}
