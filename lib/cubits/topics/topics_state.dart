part of 'topics_cubit.dart';

enum TopicsStatus { loading, success, failure }

class TopicsState extends Equatable {
  const TopicsState._(
      {this.status = TopicsStatus.loading, this.topics = const <Item>[]});

  const TopicsState.loading() : this._();

  const TopicsState.success(List<Item> topics)
      : this._(status: TopicsStatus.success, topics: topics);

  const TopicsState.failure() : this._(status: TopicsStatus.failure);

  final TopicsStatus status;
  final List<Item> topics;

  @override
  List<Object> get props => [status, topics];
}
