// File: lib/pages/widgets/buildSectionItem.dart

import 'package:flutter/material.dart';

Widget buildSectionItem(String title, IconData icon, Color color) { // Removed underscore
  return Column(
    children: [
      Icon(
        icon,
        size: 40,
        color: color,
      ),
      SizedBox(height: 8),
      Text(
        title,
        style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w500),
      ),
    ],
  );
}
