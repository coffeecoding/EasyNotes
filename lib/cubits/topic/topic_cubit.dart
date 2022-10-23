import 'package:bloc/bloc.dart';
import 'package:easynotes/cubits/item/item_cubit.dart';
import 'package:equatable/equatable.dart';

part 'topic_state.dart';

class TopicCubit extends Cubit<TopicState> {
  TopicCubit(ItemCubit? topicCubit) : super(const TopicState.empty());

  ItemCubit? get topicCubit => state.topicCubit;

  void select(ItemCubit topic) {
    switch (topic.status) {
      case ItemStatus.busy:
        return emit(TopicState.busy(topic));
      case ItemStatus.draft:
        return emit(TopicState.draft(topic));
      case ItemStatus.error:
        return emit(TopicState.error(topic));
      case ItemStatus.newDraft:
        return emit(TopicState.newDraft(topic));
      case ItemStatus.persisted:
        return emit(TopicState.persisted(topic));
    }
  }

  Future<void> save({String? title, String? color}) async {
    try {
      topicCubit!.saveLocalState(
          titleField: title ?? topicCubit!.title,
          contentField: '',
          color: color);
      emit(TopicState.busy(topicCubit!));
      final success = await topicCubit!.save();
    } catch (e) {
      print('error saving topic: $e');
      emit(TopicState.error(topicCubit!));
    }
  }
}
