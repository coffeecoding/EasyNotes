import 'package:bloc/bloc.dart';
import 'package:easynotes/cubits/cubits.dart';
import 'package:easynotes/repositories/item_repository.dart';
import 'package:equatable/equatable.dart';

part 'items_state.dart';

class ItemsCubit extends Cubit<ItemsState> {
  ItemsCubit({required this.itemRepo}) : super(const ItemsState.loading());

  final ItemRepository itemRepo;

  void selectTopic(int i) =>
      emit(ItemsState.selectionChanged(prev: state, topic: state.topics[i]));

  void selectNote(int i) => emit(ItemsState.selectionChanged(
      prev: state, note: state.topic!.state.notes[i]));

  Future<void> fetchItems() async {
    try {
      final items = await itemRepo.fetchItems();
      final topics = items.where((i) => i.isTopic).toList();
      final topicCubits = topics
          .map((t) => TopicCubit(
              topic: t,
              notes: items
                  .where((i) => i.parent_id == t.id)
                  .map((n) => NoteCubit(note: n))
                  .toList()))
          .toList();
      emit(ItemsState.success(topicCubits));
    } on Exception catch (e) {
      print("error in items_cubit fetchTopics:");
      print(e);
      emit(const ItemsState.failure());
    }
  }
}
