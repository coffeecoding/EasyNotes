part of 'search_cubit.dart';

enum SearchStatus { busy, searchTermChanged, ready }

class SearchState extends Equatable {
  const SearchState._(
      {this.status = SearchStatus.ready,
      this.searchTerm = '',
      this.results = const []});

  const SearchState.ready(
      {required List<ItemVM> results, required String searchTerm})
      : this._(
            status: SearchStatus.ready,
            results: results,
            searchTerm: searchTerm);

  SearchState.searchTermChanged(
      {required SearchState prev, required String searchTerm})
      : this._(
            status: SearchStatus.searchTermChanged,
            searchTerm: searchTerm,
            results: prev.results);

  SearchState.busy({required SearchState prev})
      : this._(
            status: SearchStatus.busy,
            searchTerm: prev.searchTerm,
            results: prev.results);

  final SearchStatus status;
  final List<ItemVM> results;
  final String searchTerm;

  @override
  List<Object> get props => [status, searchTerm, results];
}
