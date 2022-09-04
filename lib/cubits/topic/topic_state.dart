part of 'topic_cubit.dart';

enum TopicStatus { draft, saved, modified, waiting, error }

abstract class TopicState extends Equatable {
  const TopicState(
      {this.status = TopicStatus.saved,
      this.topic,
      this.notes = const <NoteCubit>[]});

  final TopicStatus status;
  final Item? topic;
  final List<NoteCubit> notes;

  @override
  List<Object?> get props => [topic, notes];
}

class DefaultTopicState extends TopicState {
  const DefaultTopicState(
      {TopicStatus status = TopicStatus.saved,
      Item? topic,
      List<NoteCubit> notes = const <NoteCubit>[]})
      : super(status: status, topic: topic, notes: notes);

  @override
  List<Object?> get props => [topic, notes];
}
