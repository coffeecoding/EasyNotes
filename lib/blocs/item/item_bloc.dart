import 'package:bloc/bloc.dart';
import 'package:easynotes/models/item.dart';
import 'package:equatable/equatable.dart';

part 'item_event.dart';
part 'item_state.dart';

class ItemBloc extends Bloc<ItemEvent, ItemBlocState> {
  ItemBloc(
      {required Item item,
      required ItemBloc parent,
      required List<ItemBloc> children})
      : super(ItemBlocState.initial(
            item: item, parent: parent, children: children)) {
    on<ItemEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
