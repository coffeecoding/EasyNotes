part of 'selected_topic_cubit.dart';

class SelectedTopicState extends Equatable {
  const SelectedTopicState(this.topic);

  final Item? topic;

  @override
  List<Object?> get props => [topic];
}
