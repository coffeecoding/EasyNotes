part of 'topic_cubit.dart';

class TopicState extends Equatable {
  const TopicState._(
      {this.status, this.topicCubit, this.colorSelection = 'ffe57373'});

  const TopicState.empty() : this._();

  const TopicState.persisted(ItemCubit? topic)
      : this._(status: ItemStatus.persisted, topicCubit: topic);

  const TopicState.newDraft(ItemCubit topic)
      : this._(status: ItemStatus.newDraft, topicCubit: topic);

  const TopicState.draft(ItemCubit topic)
      : this._(status: ItemStatus.draft, topicCubit: topic);

  const TopicState.busy(ItemCubit topic)
      : this._(status: ItemStatus.busy, topicCubit: topic);

  const TopicState.error(ItemCubit topic)
      : this._(status: ItemStatus.error, topicCubit: topic);

  final ItemStatus? status;
  final ItemCubit? topicCubit;
  final String colorSelection;

  @override
  List<Object?> get props => [status, colorSelection, topicCubit];
}
