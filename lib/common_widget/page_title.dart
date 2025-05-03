import 'package:flutter/material.dart';

class PageTitle extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  const PageTitle({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10, // Below status bar
      left: 16,
      right: 16,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Pawtection icon
          Image.asset(icon, width: 50, height: 50),
          const SizedBox(width: 12),
          // Title and subtitle
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Baloo',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(fontFamily: 'ComicNeue', fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
