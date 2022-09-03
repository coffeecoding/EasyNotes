import 'package:bloc/bloc.dart';
import 'package:easynotes/models/item.dart';
import 'package:equatable/equatable.dart';

part 'selected_topic_state.dart';

class SelectedTopicCubit extends Cubit<SelectedTopicState> {
  SelectedTopicCubit() : super(const SelectedTopicState(null));

  void select(Item? topic) => emit(SelectedTopicState(topic));
}
