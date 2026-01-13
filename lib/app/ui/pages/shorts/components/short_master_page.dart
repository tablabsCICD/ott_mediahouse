import 'package:flutter/material.dart';
import 'package:media_house/app/core/constant/image_constant.dart';
import 'package:media_house/data/models/shorts.dart';
import 'package:media_house/device/utils/ResponsiveWidget.dart';

class ShortMasterPage extends StatefulWidget {
  final ShortModel short;

  const ShortMasterPage({super.key, required this.short});

  @override
  State<ShortMasterPage> createState() => _ShortMasterPageState();
}

class _ShortMasterPageState extends State<ShortMasterPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final int totalParts = widget.short.totalParts;

    final crossAxisCount = ResponsiveWidget.isDesktop(context)
        ? 5
        : ResponsiveWidget.isTablet(context)
            ? 4
            : 2;

    final tileHeight = ResponsiveWidget.isDesktop(context)
        ? 220.0
        : ResponsiveWidget.isTablet(context)
            ? 200.0
            : 180.0;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        title: Text(
          widget.short.title,
          style: TextStyle(color: theme.canvasColor),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -----------------------------------------------------------------
            // MASTER DETAILS SECTION
            // -----------------------------------------------------------------
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Poster
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    widget.short.posterUrl,
                    height: 180,
                    width: 130,
                    fit: BoxFit.cover,
                  ),
                ),

                const SizedBox(width: 16),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                              height: 20,
                              width: 20,
                              child: Image.asset(ImageConstant.coin)),
                          Text(
                            " ${widget.short.coinsPerPart} / part",
                            style: TextStyle(
                              color: theme.canvasColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        widget.short.title,
                        style: TextStyle(
                          color: theme.canvasColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Creator: ${widget.short.creatorName}",
                        style: TextStyle(
                            color: theme.canvasColor.withOpacity(0.7)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Category: ${widget.short.category}",
                        style: TextStyle(
                            color: theme.canvasColor.withOpacity(0.7)),
                      ),
                      const SizedBox(height: 10),
                      if (widget.short.isTrending)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            "TRENDING",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      Text(
                        widget.short.description,
                        style: TextStyle(
                            color: theme.canvasColor.withOpacity(0.7)),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            // -----------------------------------------------------------------
            // PART COUNTERS
            // -----------------------------------------------------------------
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.cardColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: theme.canvasColor.withOpacity(0.1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildInfoTile("Total Parts", totalParts.toString(), theme),
                  _buildInfoTile("Views", "156", theme),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // -----------------------------------------------------------------
            // SHORT PARTS GRID TITLE
            // -----------------------------------------------------------------
            Text(
              "Short Videos",
              style: TextStyle(
                color: theme.canvasColor,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 14),

            // -----------------------------------------------------------------
            // RESPONSIVE GRID FOR SHORT PARTS
            // -----------------------------------------------------------------
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: totalParts,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                mainAxisExtent: tileHeight,
              ),
              itemBuilder: (_, index) {
                // TODO: replace with real ShortPart
                return _buildPartTile(theme,
                    index: index, partNumber: index + 1);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // REUSABLE WIDGETS
  // ==========================================================================

  Widget _buildInfoTile(String title, String value, ThemeData theme) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: theme.canvasColor,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            color: theme.canvasColor.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholderTile(ThemeData theme) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.cardColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.canvasColor.withOpacity(0.1)),
      ),
      child: Center(
        child: Text(
          "No parts uploaded yet",
          style: TextStyle(color: theme.canvasColor.withOpacity(0.6)),
        ),
      ),
    );
  }

  Widget _buildPartTile(ThemeData theme,
      {required int index, required int partNumber}) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.canvasColor.withOpacity(0.1)),
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              "Part $partNumber",
              style: TextStyle(
                color: theme.canvasColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Positioned(
            right: 8,
            bottom: 8,
            child: Icon(Icons.play_circle_fill,
                color: theme.canvasColor.withOpacity(0.7), size: 28),
          ),
        ],
      ),
    );
  }
}
