import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';

import '../../../../device/utils/ResponsiveWidget.dart';
import '../../../provider/series_provider.dart';
import '../../../widget/custom_textfield.dart';
import '../../../widget/movieCardHorizontal.dart';

class SeriesPage extends StatefulWidget {
  const SeriesPage({super.key});

  @override
  State<SeriesPage> createState() => _SeriesPageState();
}

class _SeriesPageState extends State<SeriesPage> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();

    /// ⚠️ Ensure provider call happens AFTER widget tree build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SeriesProvider>().fetchSeriesByMediaHouseId();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        automaticallyImplyLeading: false,
        title: SizedBox(
          width: ResponsiveWidget.isMobile(context) ? double.infinity : 400,
          child: CustomTextField(
            controller: _searchCtrl,
            hintText: "Search",
            textInputType: TextInputType.text,
           /* onChanged: (value) {
              context.read<SeriesProvider>().filterSeries(value);
            },*/
          ),
        ),
      ),
      body: Consumer<SeriesProvider>(
        builder: (context, provider, _) {
          /// 🔄 Always show loader while fetching
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          /// 🚫 Empty state
          if (provider.filteredContentList.isEmpty) {
            return const Center(
              child: Text(
                "No Series available",
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.fromLTRB(8, 70, 8, 10),
            child: ResponsiveWidget.isMobile(context)
                ? ListView.builder(
              itemCount: provider.filteredContentList.length,
              itemBuilder: (context, index) {
                final movie =
                provider.filteredContentList[index];
                return MovieCardHorizontal(movie: movie);
              },
            )
                : GridView.builder(
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 15,
                mainAxisSpacing: 12,
                childAspectRatio: 8 / 4,
              ),
              itemCount: provider.filteredContentList.length,
              itemBuilder: (context, index) {
                final movie =
                provider.filteredContentList[index];
                return MovieCardHorizontal(movie: movie);
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
