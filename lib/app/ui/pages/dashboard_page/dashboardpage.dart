import 'package:flutter/material.dart';
import 'package:media_house/app/provider/mediaHouseProvider.dart';
import 'package:media_house/app/provider/themeProvider.dart';
import 'package:media_house/app/provider/user_provider.dart';
import 'package:media_house/app/ui/pages/dashboard_page/components/settlementCards.dart';
import 'package:media_house/app/ui/pages/dashboard_page/components/buildSummaryCard.dart';
import 'package:media_house/app/ui/pages/dashboard_page/components/contentUploadCrad.dart';
import 'package:media_house/app/ui/pages/uploadContent_page/upload_video.dart';

import 'package:media_house/app/widget/CustomLineGraph.dart';
import 'package:media_house/app/widget/TopMoviesLineGraph.dart';
import 'package:media_house/app/widget/show_toast.dart';
import 'package:media_house/data/repositories/settlement_list.dart';
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
    if (user != null) {
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
  }

  @override
  Widget build(BuildContext context) {
    var selectedThemeData =
        Provider.of<ThemeProvider>(context, listen: true).getTheme;
    final userProvider = Provider.of<UserProvider>(context);

    return Consumer<MediaHouseProvider>(builder: (context, provider, child) {
      final mediaHouse = provider.mediaHouse;

      if (mediaHouse == null) {
        return const Center(child: CircularProgressIndicator());
      }

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
                        leading: CircleAvatar(
                          radius: 50,
                          backgroundImage:
                              NetworkImage(provider.mediaHouse.logo ?? ""),
                        ),
                        title: Text(
                          provider.mediaHouse.mediaHouseName ?? '',
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
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            BuildSummaryCard(
                              icon: Icons.currency_rupee_sharp,
                              title: "Revenue",
                              value: provider
                                  .mediaHouseDashboardData.viewRevenue
                                  .toString(),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Dialog(
                                      backgroundColor:
                                          selectedThemeData.cardColor,
                                      child: CustomLineGraph(
                                        title: 'Revenue Graph',
                                        yAxisLabel: 'sales',
                                        canPop: true,
                                        graphNumber: 0,
                                        metrics: ["revenue"],
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                            SizedBox(width: 10),
                            BuildSummaryCard(
                              icon: Icons.visibility_outlined,
                              title: "Views",
                              value: provider.mediaHouseDashboardData.totalViews
                                  .toString(),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Dialog(
                                      backgroundColor:
                                          selectedThemeData.cardColor,
                                      child: CustomLineGraph(
                                        title: 'Views Graph',
                                        yAxisLabel: 'views',
                                        canPop: true,
                                        graphNumber: 1,
                                        metrics: ["views"],
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                            SizedBox(width: 10),
                            BuildSummaryCard(
                              icon: Icons.play_circle_outline_sharp,
                              title: "Released Content",
                              value: provider
                                  .mediaHouseDashboardData.approvedContent
                                  .toString(),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Dialog(
                                      backgroundColor:
                                          selectedThemeData.cardColor,
                                      child: CustomLineGraph(
                                        title: 'Released Content',
                                        yAxisLabel: 'Released',
                                        canPop: true,
                                        graphNumber: 2,
                                        metrics: ["Released"],
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                            SizedBox(width: 10),
                            BuildSummaryCard(
                              icon: Icons.hourglass_top_outlined,
                              title: "Pending Content",
                              value: provider
                                  .mediaHouseDashboardData.pendingContentCount
                                  .toString(),
                              onTap: () {},
                            ),
                            SizedBox(width: 10),
                            BuildSummaryCard(
                              icon: Icons.schedule,
                              title: "Upcoming Content",
                              value: provider
                                  .mediaHouseDashboardData.upcomingContentCount
                                  .toString(),
                              onTap: () {},
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      SizedBox(
                        height: 400,
                        child: Card(
                          color: selectedThemeData.cardColor,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TopMoviesLineGraph(
                              isRevenue: true,
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(
                            height: 50,
                            child: CircleAvatar(
                              radius: 50,
                              backgroundImage:
                                  NetworkImage(provider.mediaHouse.logo ?? ""),
                            ),
                          ),
                          Text(
                            provider.mediaHouse.mediaHouseName ?? "",
                            style: TextStyle(
                              color: selectedThemeData.primaryColor,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Spacer(),
                          _buildActionButton(
                              selectedThemeData,
                              Icons.file_upload_outlined,
                              "Upload Content",
                              context,
                              provider),
                        ],
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
                                    value: provider
                                        .mediaHouseDashboardData.viewRevenue
                                        .toString(),
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return Dialog(
                                            backgroundColor:
                                                selectedThemeData.cardColor,
                                            child: CustomLineGraph(
                                              title: 'Revenue Graph',
                                              yAxisLabel: 'sales',
                                              canPop: true,
                                              graphNumber: 0,
                                              metrics: ["revenue"],
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                  SizedBox(width: 10),
                                  BuildSummaryCard(
                                    icon: Icons.visibility_outlined,
                                    title: "Views",
                                    value: provider
                                        .mediaHouseDashboardData.totalViews
                                        .toString(),
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return Dialog(
                                            backgroundColor:
                                                selectedThemeData.cardColor,
                                            child: CustomLineGraph(
                                              title: 'Views Graph',
                                              yAxisLabel: 'views',
                                              canPop: true,
                                              graphNumber: 1,
                                              metrics: ["views"],
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                  SizedBox(width: 10),
                                  BuildSummaryCard(
                                    icon: Icons.play_circle_outline_sharp,
                                    title: "Released Content",
                                    value: provider
                                        .mediaHouseDashboardData.approvedContent
                                        .toString(),
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return Dialog(
                                            backgroundColor:
                                                selectedThemeData.cardColor,
                                            child: CustomLineGraph(
                                              title: 'Released Content',
                                              yAxisLabel: 'Released',
                                              canPop: true,
                                              graphNumber: 2,
                                              metrics: ["Released"],
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                  SizedBox(width: 10),
                                  BuildSummaryCard(
                                    icon: Icons.hourglass_top_outlined,
                                    title: "Pending Content",
                                    value: provider.mediaHouseDashboardData
                                        .pendingContentCount
                                        .toString(),
                                    onTap: () {},
                                  ),
                                  SizedBox(width: 10),
                                  BuildSummaryCard(
                                    icon: Icons.schedule,
                                    title: "Upcoming Content",
                                    value: provider.mediaHouseDashboardData
                                        .upcomingContentCount
                                        .toString(),
                                    onTap: () {},
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                        height: 300,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: ContentUploadCrad(provider.mediaHouse),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              flex: 4,
                              child: Card(
                                color: selectedThemeData.cardColor,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TopMoviesLineGraph(
                                    isRevenue: true,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
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
            provider.mediaHouse.status == "APPROVED"
                ? showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Dialog(
                        backgroundColor: theme.cardColor,
                        child: SizedBox(
                            width: ResponsiveWidget.isMobile(context)
                                ? MediaQuery.of(context).size.width * 0.8
                                : MediaQuery.of(context).size.width *
                                    0.5, // 80% of screen width,
                            child: UploadVideoWidget()),
                      );
                    },
                  )
                : CustomToast.show("First you need to get approval from admin",
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
