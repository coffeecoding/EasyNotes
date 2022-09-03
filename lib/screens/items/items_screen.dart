import 'package:flutter/material.dart';

import '../home_screen.dart';

class ItemsScreen extends StatelessWidget {
  const ItemsScreen({Key? key}) : super(key: key);

  static const String routeName = '/items';

  static Route<dynamic> route() {
    return MaterialPageRoute<HomeScreen>(
      settings: const RouteSettings(name: routeName),
      builder: (BuildContext context) => const ItemsScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('data'));
  }
}
