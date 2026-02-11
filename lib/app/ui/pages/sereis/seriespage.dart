import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../provider/series_provider.dart';
import '../../../widget/movieCardHorizontal.dart';
import '../../../../device/utils/ResponsiveWidget.dart';

class SeriesPage extends StatefulWidget {
  const SeriesPage({super.key});

  @override
  State<SeriesPage> createState() => _SeriesPageState();
}

class _SeriesPageState extends State<SeriesPage> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SeriesProvider>().fetchSeriesByMediaHouseId();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Consumer<SeriesProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.filteredContentList.isEmpty) {
            return Center(
              child: Text(
                "No Series available",
                style: TextStyle(color: theme.canvasColor),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(8),
            child: ResponsiveWidget.isMobile(context)
                ? ListView.builder(
                    itemCount: provider.filteredContentList.length,
                    itemBuilder: (context, index) {
                      return MovieCardHorizontal(
                        movie: provider.filteredContentList[index],
                      );
                    },
                  )
                : GridView.builder(
                    itemCount: provider.filteredContentList.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 12,
                      childAspectRatio: 8 / 4,
                    ),
                    itemBuilder: (context, index) {
                      return MovieCardHorizontal(
                        movie: provider.filteredContentList[index],
                      );
                    },
                  ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }
}
