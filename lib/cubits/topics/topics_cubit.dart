import 'package:bloc/bloc.dart';
import 'package:easynotes/models/item.dart';
import 'package:equatable/equatable.dart';
import 'package:easynotes/repositories/item_repository.dart';

part 'topics_state.dart';

class TopicsCubit extends Cubit<TopicsState> {
  TopicsCubit() : super(const TopicsState.loading());
}
