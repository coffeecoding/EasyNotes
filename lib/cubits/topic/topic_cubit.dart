import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'topic_state.dart';

class TopicCubit extends Cubit<TopicState> {
  TopicCubit() : super(TopicInitial());
}
