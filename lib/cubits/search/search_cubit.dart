import 'package:bloc/bloc.dart';
import 'package:easynotes/cubits/item_vm/item_vm.dart';
import 'package:equatable/equatable.dart';

part 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit() : super(const SearchState.ready(results: [], searchTerm: ''));

  Future<void> search({required List<ItemVM> rootItems}) async {
    emit(SearchState.busy(prev: state));
    List<ItemVM> results = [];
    for (var r in rootItems) {
      results.addAll(r.search(state.searchTerm));
    }
    emit(SearchState.ready(results: results, searchTerm: state.searchTerm));
  }

  void handleItemChanging() {
    emit(SearchState.busy(prev: state));
  }

  void handleItemRemoved(ItemVM item) {
    emit(SearchState.ready(
        results: state.results.where((i) => i.id != item.id).toList(),
        searchTerm: state.searchTerm));
  }

  void handleSearchTermChanged(String newSearchTerm) {
    emit(SearchState.searchTermChanged(prev: state, searchTerm: newSearchTerm));
  }
}
