import 'package:bloc/bloc.dart';
import 'package:easynotes/models/item.dart';
import 'package:equatable/equatable.dart';
import 'package:easynotes/repositories/item_repository.dart';

part 'topics_state.dart';

class TopicsCubit extends Cubit<TopicsState> {
  TopicsCubit({required this.itemRepo}) : super(const TopicsState.loading());

  final ItemRepository itemRepo;

  Future<void> fetchTopics() async {
    try {
      final topics = await itemRepo.fetchTopics();
      emit(TopicsState.success(topics));
    } on Exception catch (e) {
      emit(const TopicsState.failure());
    }
  }
}
