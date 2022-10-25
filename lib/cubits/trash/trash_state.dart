part of 'trash_cubit.dart';

enum TrashStatus { busy, loaded, error }

class TrashState extends Equatable {
  const TrashState._({this.status = TrashStatus.busy});

  const TrashState.busy() : this._();

  const TrashState.loaded() : this._(status: TrashStatus.loaded);

  const TrashState.error() : this._(status: TrashStatus.error);

  final TrashStatus status;

  @override
  List<Object> get props => [status];
}
