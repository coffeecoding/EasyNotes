import 'package:bloc/bloc.dart';
import 'package:easynotes/cubits/item_vm/item_vm.dart';
import 'package:equatable/equatable.dart';

part 'topic_screen_state.dart';

class TopicCubit extends Cubit<TopicState> {
  TopicCubit(ItemVM? topicCubit) : super(const TopicState.empty());

  ItemVM? get topicCubit => state.topicCubit;

  void handleChanged() {
    select(topicCubit!);
  }

  void selectColor(int color) {
    if (state.status == ItemVMStatus.newDraft) {
      emit(TopicState.newDraft(topicCubit!));
    } else {
      emit(TopicState.draft(topicCubit!));
    }
  }

  void select(ItemVM topic) {
    switch (topic.status) {
      case ItemVMStatus.busy:
        return emit(TopicState.busy(topic));
      case ItemVMStatus.draft:
        return emit(TopicState.draft(topic));
      case ItemVMStatus.error:
        return emit(TopicState.error(topic));
      case ItemVMStatus.newDraft:
        return emit(TopicState.newDraft(topic));
      case ItemVMStatus.persisted:
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
