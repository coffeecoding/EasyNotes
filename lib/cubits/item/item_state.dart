part of 'item_cubit.dart';

enum ItemStatus { persisted, newDraft, draft, busy, error }

class ItemState extends Equatable {
  const ItemState._({
    this.status = ItemStatus.persisted,
    this.titleField = '',
    this.contentField = '',
    this.errorMsg = '',
    this.colorSelection = defaultItemColor,
    this.modified = 0,
  });

  const ItemState.persisted(
      {required String titleField,
      required String contentField,
      required String colorSelection,
      required int modified})
      : this._(
            status: ItemStatus.persisted,
            titleField: titleField,
            contentField: contentField,
            colorSelection: colorSelection,
            modified: modified);

  const ItemState.newDraft(
      {required String titleField,
      required String contentField,
      required String colorSelection})
      : this._(
            status: ItemStatus.newDraft,
            titleField: titleField,
            contentField: contentField,
            colorSelection: colorSelection);

  ItemState.draft(
      {required ItemState prev,
      String? titleField,
      String? contentField,
      String? colorSelection})
      : this._(
            status: ItemStatus.draft,
            titleField: titleField ?? prev.titleField,
            contentField: contentField ?? prev.contentField,
            colorSelection: prev.colorSelection,
            modified: prev.modified);

  ItemState.busy(
      {required ItemState prev,
      String? titleField,
      String? contentField,
      String? colorSelection})
      : this._(
            status: ItemStatus.busy,
            titleField: titleField ?? prev.titleField,
            contentField: contentField ?? prev.contentField,
            colorSelection: prev.colorSelection,
            modified: prev.modified);

  ItemState.error(
      {required ItemState prev,
      required String errorMsg,
      String? titleField,
      String? contentField,
      String? colorSelection})
      : this._(
            status: ItemStatus.error,
            titleField: titleField ?? prev.titleField,
            contentField: contentField ?? prev.contentField,
            colorSelection: prev.colorSelection,
            modified: prev.modified);

  final ItemStatus status;
  final String titleField;
  final String contentField;
  final String colorSelection;
  final int modified;
  final String errorMsg;

  @override
  List<Object?> get props =>
      [status, titleField, contentField, colorSelection, modified, errorMsg];
}
