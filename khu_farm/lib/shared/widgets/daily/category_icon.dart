import 'package:flutter/material.dart';

class CategoryIcon extends StatelessWidget {
  final String iconPath;

  const CategoryIcon({required this.iconPath});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(4), // 여백 최소화
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Image.asset(
              iconPath,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}