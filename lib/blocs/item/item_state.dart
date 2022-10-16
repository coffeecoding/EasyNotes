part of 'item_bloc.dart';

enum ItemBlocStatus { initial, saving, success, error }

class ItemBlocState extends Equatable {
  const ItemBlocState._({
    this.status = ItemBlocStatus.success,
    this.item,
    this.parent,
    this.children = const <ItemBloc>[],
    this.title = '',
    this.content = '',
    this.errorMsg = '',
  });

  ItemBlocState.initial({
    required Item item,
    required ItemBloc parent,
    required List<ItemBloc> children,
  }) : this._(
            status: ItemBlocStatus.initial,
            item: item,
            parent: parent,
            children: children,
            title: item.title,
            content: item.content);

  ItemBlocState.success({
    required ItemBloc prev,
    required item,
    ItemBloc? parent,
    List<ItemBloc>? children,
    String? title,
    String? content,
  }) : this._(
            status: ItemBlocStatus.success,
            item: item,
            parent: parent ?? prev.state.parent,
            children: children ?? prev.state.children,
            title: title ?? prev.state.title,
            content: content ?? prev.state.content);

  // doesn't need a lot of information: Just the updated item (containing
  // the next state); the state itself can then be used to overlay the item
  // view with an opaque layer indicating that it's being saved.
  const ItemBlocState.saving({required Item item})
      : this._(status: ItemBlocStatus.saving, item: item);

  ItemBlocState.error({
    required ItemBloc prev,
    required String errorMsg,
  }) : this._(
            status: ItemBlocStatus.error,
            item: prev.state.item,
            parent: prev.state.parent,
            children: prev.state.children,
            title: prev.state.title,
            content: prev.state.content,
            errorMsg: errorMsg);

  final ItemBlocStatus status;
  final Item? item;
  final ItemBloc? parent;
  final List<ItemBloc> children;
  final String title;
  final String content;
  final String errorMsg;

  bool isTopic() => item?.item_type == 0;
  List<ItemBloc> getAncestors() {
    throw 'getAncestors is not yet implemented';
  }

  @override
  List<Object?> get props =>
      [status, title, content, errorMsg, children, item, parent];
}
