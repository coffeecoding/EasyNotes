part of 'search_cubit.dart';

enum SearchStatus { busy, ready }

class SearchState extends Equatable {
  const SearchState._(
      {this.status = SearchStatus.ready, this.results = const []});

  const SearchState.ready({required List<ItemVM> results})
      : this._(status: SearchStatus.ready, results: results);

  SearchState.busy({required SearchState prev})
      : this._(status: SearchStatus.busy, results: prev.results);

  final SearchStatus status;
  final List<ItemVM> results;

  @override
  List<Object> get props => [status, results];
}
