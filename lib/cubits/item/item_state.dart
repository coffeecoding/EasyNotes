part of 'item_cubit.dart';

enum ItemStatus { initial, saving, success, error }

class ItemState extends Equatable {
  const ItemState._({
    this.status = ItemStatus.success,
    this.parent,
    this.title = '',
    this.content = '',
    this.errorMsg = '',
  });

  const ItemState.initial({
    required ItemCubit? parent,
    required String title,
    required String content,
  }) : this._(
            status: ItemStatus.initial,
            parent: parent,
            title: title,
            content: content);

  ItemState.success({
    required ItemState prev,
    ItemCubit? parent,
    String? title,
    String? content,
  }) : this._(
            status: ItemStatus.success,
            parent: parent ?? prev.parent,
            title: title ?? prev.title,
            content: content ?? prev.content);

  // doesn't need a lot of information: Just the updated item (containing
  // the next state); the state itself can then be used to overlay the item
  // view with an opaque layer indicating that it's being saved.
  const ItemState.saving() : this._(status: ItemStatus.saving);

  ItemState.error({
    required ItemState prev,
    required String errorMsg,
  }) : this._(
            status: ItemStatus.error,
            parent: prev.parent,
            title: prev.title,
            content: prev.content,
            errorMsg: errorMsg);

  final ItemStatus status;
  final ItemCubit? parent;
  final String title;
  final String content;
  final String errorMsg;

  @override
  List<Object?> get props => [status, title, content, errorMsg, parent];
}
