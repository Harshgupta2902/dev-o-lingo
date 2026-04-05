import 'package:flutter/material.dart';
import 'package:lingolearn/utilities/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class OverviewResource {
  final String type;
  final String title;
  final String url;
  OverviewResource({required this.type, required this.title, required this.url});
}

class CourseOverviewCard extends StatelessWidget {
  final String description;
  final List<OverviewResource> resources;
  final Color themeColor;

  const CourseOverviewCard({
    super.key,
    required this.description,
    required this.resources,
    required this.themeColor,
  });

  Future<void> _openLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (description.isEmpty && resources.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (description.isNotEmpty)
          Text(
            description,
            style: const TextStyle(
              fontSize: 16,
              height: 1.6,
              color: kDarkSlate,
              fontWeight: FontWeight.w500,
            ),
          ),
        if (resources.isNotEmpty) ...[
          const SizedBox(height: 24),
          // Divider & Label
          Row(
            children: [
              Expanded(child: Divider(color: themeColor.withValues(alpha: 0.3), thickness: 1.5)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: themeColor.withValues(alpha: 0.3), width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome_rounded, size: 16, color: themeColor),
                    const SizedBox(width: 8),
                    Text(
                      "LEARNING RESOURCES",
                      style: TextStyle(
                        color: themeColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(child: Divider(color: themeColor.withValues(alpha: 0.3), thickness: 1.5)),
            ],
          ),
          const SizedBox(height: 24),
          // Resource Items
          ...resources.map((res) => _buildResourceItem(res)),
        ],
      ],
    );
  }

  Widget _buildResourceItem(OverviewResource res) {
    Color labelColor;
    String label;

    switch (res.type.toLowerCase()) {
      case 'video':
        labelColor = Colors.purple.shade200;
        label = 'Video';
        break;
      case 'article':
        labelColor = Colors.amber.shade300;
        label = 'Article';
        break;
      case 'official':
        labelColor = Colors.blue.shade200;
        label = 'Official';
        break;
      case 'feed':
        labelColor = Colors.teal.shade200;
        label = 'Feed';
        break;
      default:
        labelColor = Colors.grey.shade300;
        label = 'Info';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _openLink(res.url),
        borderRadius: BorderRadius.circular(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 70,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: labelColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                res.title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: kDarkSlate,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.arrow_outward_rounded, size: 14, color: kMuted),
          ],
        ),
      ),
    );
  }
}
