import 'package:flutter/material.dart';
import 'badge_screen.dart';
import 'records_screen.dart';
import '../theme/colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          bottom: TabBar(
            labelColor: AppColors.white,
            unselectedLabelColor: AppColors.white.withOpacity(0.7),
            indicatorColor: AppColors.white,
            tabs: const [
              Tab(
                icon: Icon(Icons.badge),
                text: 'Badge',
              ),
              Tab(
                icon: Icon(Icons.history),
                text: 'Records',
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            BadgeScreen(),
            RecordsScreen(),
          ],
        ),
      ),
    );
  }
}