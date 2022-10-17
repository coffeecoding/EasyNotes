part of 'item_cubit.dart';

enum ItemStatus { initial, populated, saving, success, error }

class ItemState extends Equatable {
  const ItemState._({
    this.status = ItemStatus.success,
    this.parent,
    this.children = const <ItemCubit>[],
    this.title = '',
    this.content = '',
    this.errorMsg = '',
  });

  const ItemState.initial({
    required ItemCubit? parent,
  }) : this._(
            status: ItemStatus.initial, parent: parent, title: '', content: '');

  const ItemState.populated({
    required ItemCubit? parent,
    required List<ItemCubit> children,
    required String title,
    required String content,
  }) : this._(
            status: ItemStatus.populated,
            parent: parent,
            children: children,
            title: title,
            content: content);

  ItemState.success({
    required ItemState prev,
    ItemCubit? parent,
    List<ItemCubit>? children,
    String? title,
    String? content,
  }) : this._(
            status: ItemStatus.success,
            parent: parent ?? prev.parent,
            children: children ?? prev.children,
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
            children: prev.children,
            title: prev.title,
            content: prev.content,
            errorMsg: errorMsg);

  final ItemStatus status;
  final ItemCubit? parent;
  final List<ItemCubit> children;
  final String title;
  final String content;
  final String errorMsg;

  @override
  List<Object?> get props =>
      [status, title, content, errorMsg, children, parent];
}
