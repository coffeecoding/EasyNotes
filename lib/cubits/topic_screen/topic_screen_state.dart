part of 'topic_screen_cubit.dart';

class TopicState extends Equatable {
  const TopicState._({this.topicCubit, this.status});

  const TopicState.empty() : this._();

  const TopicState.persisted(ItemVM? topic)
      : this._(status: ItemVMStatus.persisted, topicCubit: topic);

  const TopicState.newDraft(ItemVM topic)
      : this._(status: ItemVMStatus.newDraft, topicCubit: topic);

  const TopicState.draft(ItemVM topic)
      : this._(status: ItemVMStatus.draft, topicCubit: topic);

  const TopicState.busy(ItemVM topic)
      : this._(status: ItemVMStatus.busy, topicCubit: topic);

  const TopicState.error(ItemVM topic)
      : this._(status: ItemVMStatus.error, topicCubit: topic);

  final ItemVMStatus? status;
  final ItemVM? topicCubit;

  @override
  List<Object?> get props => [status, topicCubit];
}
