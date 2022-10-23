import 'package:bloc/bloc.dart';
import 'package:easynotes/cubits/item/item_cubit.dart';
import 'package:equatable/equatable.dart';

part 'topic_state.dart';

class TopicCubit extends Cubit<TopicState> {
  TopicCubit() : super(const TopicState.empty());

  ItemCubit? get topicCubit => state.topicCubit;

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
