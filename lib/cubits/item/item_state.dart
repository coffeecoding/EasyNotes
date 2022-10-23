part of 'item_cubit.dart';

enum ItemStatus { persisted, newDraft, draft, busy, error }

class ItemState extends Equatable {
  const ItemState._({
    this.status = ItemStatus.newDraft,
  });

  const ItemState.persisted() : this._(status: ItemStatus.persisted);

  const ItemState.newDraft()
      : this._(
          status: ItemStatus.newDraft,
        );

  const ItemState.draft() : this._(status: ItemStatus.draft);

  const ItemState.busy() : this._(status: ItemStatus.busy);

  const ItemState.error() : this._(status: ItemStatus.error);

  final ItemStatus status;

  @override
  List<Object?> get props => [status];
}
