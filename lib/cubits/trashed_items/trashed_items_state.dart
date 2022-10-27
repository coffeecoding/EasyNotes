part of 'trashed_items_cubit.dart';

enum TrashedItemsStatus { busy, busySilent, ready, error }

class TrashedItemsState extends Equatable {
  const TrashedItemsState._(
      {this.items = const <ItemVM>[], this.status = TrashedItemsStatus.busy});

  const TrashedItemsState.initial() : this._();

  TrashedItemsState.busy({required TrashedItemsState prev})
      : this._(items: prev.items);

  TrashedItemsState.busySilent({required TrashedItemsState prev})
      : this._(status: TrashedItemsStatus.busySilent, items: prev.items);

  TrashedItemsState.ready({
    required TrashedItemsState prev,
    List<ItemVM>? items,
  }) : this._(status: TrashedItemsStatus.ready, items: items ?? prev.items);

  TrashedItemsState.error({
    required TrashedItemsState prev,
    List<ItemVM>? items,
  }) : this._(items: items ?? prev.items, status: TrashedItemsStatus.error);

  final TrashedItemsStatus status;
  final List<ItemVM> items;

  @override
  List<Object> get props => [status, items];
}
