// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'items_cubit.dart';

enum ItemsStatus { loading, success, error }

class ItemsState extends Equatable {
  const ItemsState._(
      {this.status = ItemsStatus.loading,
      this.topics = const <TopicCubit>[],
      this.notes = const <NoteCubit>[],
      this.note,
      this.topic});

  const ItemsState.loading() : this._();

  const ItemsState.success(List<TopicCubit> topics)
      : this._(status: ItemsStatus.success, topics: topics);

  ItemsState.selectionChanged({
    required ItemsState prev,
    TopicCubit? topic,
    NoteCubit? note,
  }) : this._(
          status: prev.status,
          topics: prev.topics,
          notes: prev.notes,
          topic: topic ?? prev.topic,
          note: note ?? prev.note,
        );

  const ItemsState.failure() : this._(status: ItemsStatus.error);

  final ItemsStatus status;
  final List<TopicCubit> topics;
  final List<NoteCubit> notes;
  final TopicCubit? topic;
  final NoteCubit? note;

  @override
  List<Object?> get props => [status, topics, notes, topic, note];

  ItemsState copyWith({
    ItemsStatus? status,
    List<TopicCubit>? topics,
    List<NoteCubit>? notes,
    TopicCubit? topic,
    NoteCubit? note,
  }) {
    return ItemsState._(
      status: status ?? this.status,
      topics: topics ?? this.topics,
      notes: notes ?? this.notes,
      topic: topic ?? this.topic,
      note: note ?? this.note,
    );
  }
}
