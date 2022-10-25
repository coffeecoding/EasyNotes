export 'preference/preference_cubit.dart';
// RootItemsCubit holds the state (that is the listitem-state) of
// - the root items list
// - the child items list (children of selected root item)
// - the currently selected leaf item (note) and it's state inside the list
export 'root_items/root_items_cubit.dart';
// itemCubit holds the state of
// - any particular item
//export 'item/item_cubit.dart';
// selection cubit will hold the state of *multiple* selected items
// for bulk deletion or bulk moving [Deleted for now]
// export 'selection/selection_cubit.dart';
// selectedNoteCubit is a wrapper around the itemCubit of the currently
// selected leaf (note); it handles the state of the *note screen*,
// which is for editing a single note or creating a new one
export 'selected_note/selected_note_cubit.dart';
// like selectedNoteCubit, it's a wrapper around the itemCubit of the currently
// selected topic item; it handles the state of the *topic screen*,
// which is for editing a single topic or creating a new one
export 'topic_screen/topic_screen_cubit.dart';
export 'children_items/children_items_cubit.dart';
