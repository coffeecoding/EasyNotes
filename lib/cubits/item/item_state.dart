part of 'item_cubit.dart';

enum ItemStatus { persisted, newDraft, draft, busy, error }

class ItemState extends Equatable {
  const ItemState._({
    this.status = ItemStatus.persisted,
    this.titleField = '',
    this.contentField = '',
    this.errorMsg = '',
  });

  const ItemState.persisted(
      {required String titleField, required String contentField})
      : this._(
            status: ItemStatus.persisted,
            titleField: titleField,
            contentField: contentField);

  const ItemState.newDraft() : this._(status: ItemStatus.newDraft);

  const ItemState.draft(
      {required String titleField, required String contentField})
      : this._(
            status: ItemStatus.draft,
            titleField: titleField,
            contentField: contentField);

  const ItemState.busy(
      {required String titleField, required String contentField})
      : this._(
            status: ItemStatus.busy,
            titleField: titleField,
            contentField: contentField);

  const ItemState.error({
    required String titleField,
    required String contentField,
    required String errorMsg,
  }) : this._(
            status: ItemStatus.error,
            titleField: titleField,
            contentField: contentField,
            errorMsg: errorMsg);

  final ItemStatus status;
  final String titleField;
  final String contentField;
  final String errorMsg;

  @override
  List<Object?> get props => [status, errorMsg];
}
