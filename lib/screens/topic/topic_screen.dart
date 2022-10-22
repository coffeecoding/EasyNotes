import 'package:easynotes/cubits/topic/topic_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TopicCubit, TopicState>(
      builder: (context, state) {
        //TextEditingController titleCtr = TextEditingController(text: state.)
        return SingleChildScrollView(
            child: Column(
          children: [
            Center(
              child: Text('hi'),
            )
          ],
        ));
      },
    );
  }
}
