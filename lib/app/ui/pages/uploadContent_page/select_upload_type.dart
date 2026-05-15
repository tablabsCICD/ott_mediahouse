import 'package:flutter/material.dart';
import 'package:media_house/app/ui/pages/shorts/components/add_short_master.dart';
import 'package:media_house/app/ui/pages/uploadContent_page/upload_video.dart';
import 'package:media_house/device/utils/ResponsiveWidget.dart';
import 'package:provider/provider.dart';
import 'package:media_house/app/provider/themeProvider.dart';

class SelectUploadTypeDialog extends StatelessWidget {
  const SelectUploadTypeDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context, listen: false).getTheme;

    return Dialog(
      backgroundColor: theme.cardColor,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: IntrinsicWidth(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    "Select Upload Type",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 30),
                  ResponsiveWidget.isMobile(context)
                      ? _mobileLayout(theme, context)
                      : _bentoLayout(theme, context),
                ],
              ),

              /// Close Button
              Positioned(
                left: 0,
                top: 0,
                child: InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.canvasColor.withValues(alpha: 0.05),
                    ),
                    child: const Icon(Icons.close, size: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 📱 Mobile (Stacked Clean)
  Widget _mobileLayout(ThemeData theme, BuildContext context) {
    const spacing = 16.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 250,
          child: _card(theme, "Upload Movie", Icons.movie, 16 / 9, context),
        ),
        const SizedBox(height: spacing),
        SizedBox(
          width: 250,
          child: _card(theme, "Upload Series", Icons.tv, 16 / 9, context),
        ),
        const SizedBox(height: spacing),
        SizedBox(
          width: 150,
          child: _card(
              theme, "Upload Short", Icons.smart_display, 9 / 16, context),
        ),
      ],
    );
  }

  /// 🖥 Tablet + Desktop Bento
  Widget _bentoLayout(ThemeData theme, BuildContext context) {
    const spacing = 16.0;

    const movieWidth = 340.0;
    const shortWidth = 220.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: movieWidth,
              child: _card(theme, "Upload Movie", Icons.movie, 16 / 9, context),
            ),
            const SizedBox(height: spacing),
            SizedBox(
              width: movieWidth,
              child: _card(theme, "Upload Series", Icons.tv, 16 / 9, context),
            ),
          ],
        ),
        const SizedBox(width: spacing),
        SizedBox(
          width: shortWidth,
          child: _card(theme, "Upload Mini Series", Icons.smart_display, 9 / 16,
              context),
        ),
      ],
    );
  }

  Widget _card(
    ThemeData theme,
    String title,
    IconData icon,
    double aspectRatio,
    BuildContext context,
  ) {
    return UploadTypeCard(
      title: title,
      icon: icon,
      aspectRatio: aspectRatio,
      theme: theme,
      onTap: () {
        Navigator.pop(context);
        // Handle card tap here
        title == "Upload Mini Series"
            ? AddShortMaster.show(context)
            : showDialog(
                context: context,
                builder: (BuildContext context) {
                  final uploadType = title == "Upload Movie"
                      ? UploadContentType.movie
                      : UploadContentType.series;
                  return Dialog(
                    backgroundColor: theme.cardColor,
                    child: SizedBox(
                        width: ResponsiveWidget.isMobile(context)
                            ? MediaQuery.of(context).size.width * 0.8
                            : MediaQuery.of(context).size.width *
                                0.5, // 80% of screen width,
                        child: UploadVideoWidget(uploadType: uploadType)),
                  );
                },
              );
      },
    );
  }
}

class UploadTypeCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final double aspectRatio;
  final ThemeData theme;
  final VoidCallback onTap;

  const UploadTypeCard({
    super.key,
    required this.title,
    required this.icon,
    required this.aspectRatio,
    required this.theme,
    required this.onTap,
  });

  @override
  State<UploadTypeCard> createState() => _UploadTypeCardState();
}

class _UploadTypeCardState extends State<UploadTypeCard> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => hover = true),
      onExit: (_) => setState(() => hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: widget.theme.canvasColor.withValues(alpha: 0.15),
            border: Border.all(
              color: hover ? widget.theme.primaryColor : Colors.transparent,
              width: 2,
            ),
            boxShadow: hover
                ? [
                    BoxShadow(
                      color: widget.theme.primaryColor.withValues(alpha: 0.2),
                      blurRadius: 20,
                    )
                  ]
                : [],
          ),
          child: AspectRatio(
            aspectRatio: widget.aspectRatio, // 🔥 Constant forever
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.icon,
                    size: 46,
                    color: widget.theme.primaryColor,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: widget.theme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
