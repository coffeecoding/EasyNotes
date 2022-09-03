import 'package:easynotes/extensions/color_ext.dart';
import 'package:easynotes/models/item.dart';
import 'package:easynotes/models/sample_data.dart';
import 'package:easynotes/screens/items/items_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  static const String routeName = '/';

  static Route<dynamic> route() {
    return MaterialPageRoute<HomeScreen>(
      settings: const RouteSettings(name: routeName),
      builder: (BuildContext context) => const HomeScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Item> topics = SampleData.SampleItems.where((i) => i.isTopic).toList();
    return SafeArea(
        child: Scaffold(
      body: Row(children: [
        Expanded(flex: 1, child: ItemsScreen()),
        VerticalDivider(),
        Expanded(flex: 3, child: Center(child: Text('detail')))
      ]),
    ));
  }
}
