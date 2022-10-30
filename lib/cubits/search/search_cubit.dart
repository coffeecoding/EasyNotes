import 'package:bloc/bloc.dart';
import 'package:easynotes/cubits/item_vm/item_vm.dart';
import 'package:equatable/equatable.dart';

part 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit() : super(const SearchState.ready(results: []));
}
