import 'package:flutter/material.dart';

class CustomBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabSelected;

  CustomBottomNavigation(
      {required this.currentIndex, required this.onTabSelected});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTabSelected,
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Geschichten'),
        BottomNavigationBarItem(
            icon: Icon(Icons.settings), label: 'Einstellungen'),
      ],
    );
  }
}
