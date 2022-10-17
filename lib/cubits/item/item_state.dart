part of 'item_cubit.dart';

enum ItemStatus { persisted, newDraft, draft, busy, error }

class ItemState extends Equatable {
  const ItemState._({
    this.status = ItemStatus.persisted,
    this.errorMsg = '',
  });

  const ItemState.persisted() : this._(status: ItemStatus.persisted);

  const ItemState.newDraft() : this._(status: ItemStatus.newDraft);

  const ItemState.draft() : this._(status: ItemStatus.draft);

  const ItemState.busy() : this._(status: ItemStatus.busy);

  const ItemState.error({
    required String errorMsg,
  }) : this._(status: ItemStatus.error, errorMsg: errorMsg);

  final ItemStatus status;
  final String errorMsg;

  @override
  List<Object?> get props => [status, errorMsg];
}
