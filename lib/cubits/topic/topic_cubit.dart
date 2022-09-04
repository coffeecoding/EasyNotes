import 'package:bloc/bloc.dart';
import 'package:easynotes/cubits/cubits.dart';
import 'package:easynotes/models/item.dart';
import 'package:equatable/equatable.dart';

part 'topic_state.dart';

class TopicCubit extends Cubit<TopicState> {
  TopicCubit({Item? topic, List<NoteCubit> notes = const <NoteCubit>[]})
      : super(DefaultTopicState(
            status: TopicStatus.saved, topic: topic, notes: notes));

  void select(Item? topic) => emit(DefaultTopicState(topic: topic));
}
