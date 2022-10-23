import 'package:bloc/bloc.dart';
import 'package:easynotes/cubits/item/item_cubit.dart';
import 'package:equatable/equatable.dart';

part 'topic_state.dart';

class TopicCubit extends Cubit<TopicState> {
  TopicCubit(ItemCubit? topicCubit) : super(const TopicState.empty());

  ItemCubit? get topicCubit => state.topicCubit;

  void handleChanged() {
    select(topicCubit!);
  }

  void selectColor(int color) {
    if (state.status == ItemStatus.newDraft) {
      emit(TopicState.newDraft(topicCubit!));
    } else {
      emit(TopicState.draft(topicCubit!));
    }
  }

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

  Future<bool> save({String? title, String? color}) async {
    try {
      emit(TopicState.busy(topicCubit!));
      final success =
          await topicCubit!.save(titleField: title, colorSelection: color);
      if (success) {
        handleChanged();
        return success;
      }
      print('error saving topic');
      emit(TopicState.error(topicCubit!));
      return false;
    } catch (e) {
      print('error saving topic: $e');
      emit(TopicState.error(topicCubit!));
      return false;
    }
  }
}
