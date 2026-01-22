import 'package:flutter/material.dart';
import 'package:media_house/app/core/constant/image_constant.dart';
import 'package:media_house/app/provider/shorts_provider.dart';
import 'package:media_house/app/ui/pages/shorts/components/add_short_master.dart';
import 'package:media_house/app/ui/pages/shorts/components/short_master_page.dart';
import 'package:media_house/app/widget/custom_textfield.dart';
import 'package:media_house/device/utils/ResponsiveWidget.dart';
import 'package:provider/provider.dart';

class ShortsPage extends StatefulWidget {
  const ShortsPage({super.key});

  @override
  State<ShortsPage> createState() => _ShortsPageState();
}

class _ShortsPageState extends State<ShortsPage> {
  @override
  void initState() {
    super.initState();
    context.read<ShortProvider>().fetchShorts();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final crossAxisCount = ResponsiveWidget.isDesktop(context)
        ? 5
        : ResponsiveWidget.isTablet(context)
        ? 4
        : 2;

    final tileHeight = ResponsiveWidget.isDesktop(context) ||
        ResponsiveWidget.isTablet(context)
        ? 300.0
        : 240.0;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        automaticallyImplyLeading: false,
        title: SizedBox(
          width: ResponsiveWidget.isMobile(context) ? double.infinity : 400,
          child: CustomTextField(
            controller: TextEditingController(),
            hintText: "Search",
            textInputType: TextInputType.text,
          ),
        ),
      ),
      body: Consumer<ShortProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.shorts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.shorts.isEmpty) {
            return const Center(
              child: Text(
                "No short films available",
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          /// Add “Add New Short” as first Bento tile
          final shorts = provider.shorts;
          final totalItems = shorts.length + 1; // +1 for Add Button

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: totalItems,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 14,
                crossAxisSpacing: 12,
                mainAxisExtent: tileHeight,
              ),
              itemBuilder: (_, index) {
                /// FIRST BOX = "Add Short" tile
                if (index == 0) {
                  return _buildAddShortTile(theme);
                }

                final short = shorts[index - 1];

                return _buildShortTile(short, theme);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: theme.primaryColor,
        onPressed: () {
          AddShortMaster.show(context);
        },
        tooltip: 'Add Short',
        child: Icon(
          Icons.play_circle_fill_sharp,
          color: Colors.white,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ADD SHORT TILE
  // ---------------------------------------------------------------------------
  Widget _buildAddShortTile(ThemeData theme) {
    return GestureDetector(
      onTap: () => AddShortMaster.show(context),
      child: Container(
        decoration: BoxDecoration(
          color: theme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: theme.primaryColor.withOpacity(0.4),
            width: 1.3,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 90, child: Image.asset(ImageConstant.upload)),
              SizedBox(height: 30),
              Text("Add New Short",
                  style: TextStyle(
                      color: theme.canvasColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SHORT ITEM TILE (BENTO STYLE)
  // ---------------------------------------------------------------------------
  Widget _buildShortTile(dynamic short, ThemeData theme) {
    return GestureDetector(
      onTap: () async {
        await context.read<ShortProvider>().fetchShortDetail(shortId:short.id, userId: 1);
      },
      child: GestureDetector(
        onTap: () async {
          final deleted = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => ShortMasterPage(shortId: short.id,),
            ),
          );

          if (deleted == true && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Short deleted successfully"),
                behavior: SnackBarBehavior.floating,
              ),
            );

            context.read<ShortProvider>().fetchShorts(); // refresh list
          }

        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Poster Image
              Image.network(
                short.posterUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.broken_image,
                    color: Colors.grey, size: 40),
              ),

              // Gradient overlay (bento look)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.05),
                      Colors.black.withOpacity(0.5),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),

              // Trending Badge
              if (short.isTrending)
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "TRENDING",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

              // Title + Parts
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      short.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.play_arrow_rounded,
                            color: Colors.white70, size: 14),
                        const SizedBox(width: 4),
                        Text("${short.totalParts} Parts",
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),

              // Play Icon
              const Positioned(
                bottom: 10,
                right: 10,
                child: Icon(Icons.play_circle_fill,
                    color: Colors.white70, size: 30),
              ),
            ],
          ),
        ),
      ),
    );
  }
}