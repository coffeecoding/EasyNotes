import 'package:easynotes/blocs/blocs.dart';
import 'package:easynotes/cubits/cubits.dart';
import 'package:easynotes/screens/items/components/children_list.dart';
import 'package:easynotes/screens/items/components/topics_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../home_screen.dart';

class ItemsScreen extends StatefulWidget {
  const ItemsScreen({Key? key}) : super(key: key);

  static const String routeName = '/items';

  static Route<dynamic> route() {
    return MaterialPageRoute<HomeScreen>(
      settings: const RouteSettings(name: routeName),
      builder: (BuildContext context) => const ItemsScreen(),
    );
  }

  @override
  State<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen> {
  @override
  void initState() {
    super.initState();
    if (BlocProvider.of<AuthBloc>(context).state.status ==
        AuthStatus.authenticated) {
      BlocProvider.of<ItemsCubit>(context).fetchItems();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ItemsCubit, ItemsState>(
        buildWhen: (p, n) => p.status != n.status,
        builder: (context, state) {
          switch (state.status) {
            case ItemsStatus.loading:
              // todo: here add placeholder views
              return const Center(child: CircularProgressIndicator());
            case ItemsStatus.error:
              return const Center(
                  child: Text('Failed to retrieve notes ... :('));
            default:
              return Stack(children: [
                Row(children: const [
                  Expanded(flex: 1, child: TopicsList()),
                  VerticalDivider(
                    indent: 0,
                    endIndent: 0,
                    width: 1,
                  ),
                  Expanded(flex: 2, child: ChildrenList()),
                ]),
                state.status == ItemsStatus.busy
                    ? Positioned.fill(
                        child: Container(
                            color: Colors.black26,
                            child: const Center(
                                child: CircularProgressIndicator())))
                    : Container(),
              ]);
          }
        });
  }
}

class PlaceholderRootItem extends StatelessWidget {
  const PlaceholderRootItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class PlaceholderSubtopic extends StatelessWidget {
  const PlaceholderSubtopic({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class PlaceholderSubItem extends StatelessWidget {
  const PlaceholderSubItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
