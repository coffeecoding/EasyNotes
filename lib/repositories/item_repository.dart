// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:easynotes/config/locator.dart';
import 'package:easynotes/extensions/http_client_ext.dart';
import 'package:easynotes/models/item.dart';
import 'package:easynotes/services/crypto_service.dart';
import 'package:http/http.dart';

import '../models/item_header.dart';
import '../models/item_position_data.dart';
import '../services/network_provider.dart';
import 'preference_repository.dart';

enum ItemUpdateAction { none, insert, update, updateHeaderOnly }

abstract class ItemRepository {
  Future<List<Item>> setItems(List<Item> items);
  List<Item> getItems();
  List<Item> getRootItems();
  List<Item> getTrashedItems();
  Future<List<Item>> fetchItems();
  Future<List<Item>> fetchUntrashedItems();
  Future<List<Item>> fetchTrashedItems();
  Future<List<Item>> fetchRootItems();
  Future<Item> insertOrUpdateItem(Item item, ItemUpdateAction action);
  Future<List<Item>> insertOrUpdateItems(List<Item> items);
  Future<Item> updateItemHeader(ItemHeader header);
  Future<Item> updateItemParent(String id, String? parent_id, [bool? untrash]);
  Future<Item> updateItemTrashed(String id, int? trashed);
  Future<Item> updateItemPinned(String id, int pin);
  Future<Item> updateItemGloballyPinned(String id, int pin);
  Future<List<Item>> updateItemPositions(ItemPositionData ipd);
  Future<bool> delete(String id);
  Future<bool> deleteItems(List<String> ids);

  Future<Item> createNewItem(
      {required String? parent_id, required String color, required int type});
}

class ItemRepo implements ItemRepository {
  ItemRepo()
      : netClient = locator.get<NetworkProvider>(),
        cryptoService = locator.get<CryptoService>(),
        prefsRepo = locator.get<PreferenceRepository>();

  late NetworkProvider netClient;
  late CryptoService cryptoService;
  late PreferenceRepository prefsRepo;

  List<Item> items = <Item>[];
  List<Item> trashedItems = <Item>[];

  @override
  Future<Item> createNewItem(
      {required String? parent_id,
      required String color,
      required int type}) async {
    return Item.empty(
      color: color,
      parent_id: parent_id,
      receiver_id: (await prefsRepo.username)!,
      type: type,
    );
  }

  // This function is used when initially getting the items from the auth_bloc
  // since they are already returned upon logging in
  @override
  Future<List<Item>> setItems(List<Item> items) async {
    items = await cryptoService.decryptItems(items);
    return items;
  }

  @override
  List<Item> getItems() => items.where((i) => i.trashed == null).toList();

  @override
  List<Item> getRootItems() => items.where((i) => i.parent_id == null).toList();

  @override
  List<Item> getTrashedItems() =>
      items.where((i) => i.trashed != null).toList();

  @override
  Future<List<Item>> fetchItems() async {
    Response response = await netClient.get('/api/items');
    if (!response.isSuccessStatusCode()) throw 'Unable to fetch data';
    List<Item> encryptedItems = (jsonDecode(response.body) as List)
        .map((i) => Item.fromJson(i))
        .toList();
    items = await cryptoService.decryptItems(encryptedItems);
    return getItems();
  }

  @override
  Future<List<Item>> fetchUntrashedItems() async {
    Response response = await netClient.get('/api/items?trashed=false');
    if (!response.isSuccessStatusCode()) throw 'Unable to fetch data';
    List<Item> encryptedItems = (jsonDecode(response.body) as List)
        .map((i) => Item.fromJson(i))
        .toList();
    final untrashedItems = await cryptoService.decryptItems(encryptedItems);
    //items.removeWhere((i) => i.trashed != null);
    //items.addAll(trashedItems);
    return untrashedItems;
  }

  @override
  Future<List<Item>> fetchTrashedItems() async {
    Response response = await netClient.get('/api/items?trashed=asdf');
    if (!response.isSuccessStatusCode()) throw 'Unable to fetch data';
    List<Item> encryptedItems = (jsonDecode(response.body) as List)
        .map((i) => Item.fromJson(i))
        .toList();
    final trashedItems = await cryptoService.decryptItems(encryptedItems);
    //items.removeWhere((i) => i.trashed != null);
    //items.addAll(trashedItems);
    return trashedItems;
  }

  @override
  Future<List<Item>> fetchRootItems() async {
    Response response = await netClient.post('/api/items', "");
    if (!response.isSuccessStatusCode()) throw 'Unable to fetch data';
    List<Item> encryptedItems = (jsonDecode(response.body) as List)
        .map((i) => Item.fromJson(i))
        .toList();
    items.removeWhere((i) => i.parent_id == null);
    final rootItems = await cryptoService.decryptItems(encryptedItems);
    items.addAll(rootItems);
    return rootItems;
  }

  @override
  Future<Item> insertOrUpdateItem(Item item, ItemUpdateAction action) async {
    Item encrypted = await cryptoService.encryptItem(item);
    Response? response =
        await netClient.post('/api/item', jsonEncode(encrypted));
    if (!response.isSuccessStatusCode()) throw 'Error saving item';
    String newId = response.body;
    items.removeWhere((element) => element.id == item.id);
    Item updated = item.copyWith(id: newId, trashed: item.trashed);
    items.add(updated);
    return updated;
  }

  @override
  Future<List<Item>> insertOrUpdateItems(List<Item> items) async {
    List<Item> encryptedItems = await cryptoService.encryptItems(items);
    Response? response =
        await netClient.post('/api/items', jsonEncode(encryptedItems));
    if (!response.isSuccessStatusCode()) throw 'Error saving item';
    // Improve this: 1) Return the inserted items from API, 2) only update
    // those locally, not all
    return await fetchItems();
  }

  @override
  Future<Item> updateItemHeader(ItemHeader header) async {
    Response? response =
        await netClient.put('/api/item/header', jsonEncode(header));
    if (!response.isSuccessStatusCode()) throw 'Error updating item header';
    int i = items.indexWhere((i) => i.id == header.id);
    items[i] = items[i].copyWithHeader(header);
    return items[i];
  }

  @override
  Future<Item> updateItemParent(String id, String? parent_id,
      [bool? untrash]) async {
    Response? response = await netClient.put(
        '/api/item/$id?parent_id=$parent_id${untrash == true ? '?untrash=$untrash' : ''}',
        "");
    if (!response.isSuccessStatusCode()) throw 'Error updating item parent';
    int timestamp = int.parse(response.body);
    int i = items.indexWhere((i) => i.id == id);
    items[i] = items[i].copyWith(
        parent_id: parent_id,
        modified_header: timestamp,
        trashed: items[i].trashed);
    return items[i];
  }

  @override
  Future<Item> updateItemTrashed(String id, int? trashed) async {
    Response? response =
        await netClient.put('/api/item/$id?trashed=$trashed', "");
    if (!response.isSuccessStatusCode()) throw 'Error updating item trashed';
    int timestamp = int.parse(response.body);
    int i = items.indexWhere((i) => i.id == id);
    items[i] = items[i]
        .copyWith(trashed: trashed, modified_header: trashed ?? timestamp);
    return items[i];
  }

  @override
  Future<Item> updateItemPinned(String id, int pin) async {
    Response? response = await netClient.put('/api/item/$id?pin=$pin', "");
    if (!response.isSuccessStatusCode()) throw 'Error updating item pinned';
    int timestamp = int.parse(response.body);
    int i = items.indexWhere((i) => i.id == id);
    items[i] = items[i].copyWith(
        pinned: pin != 0,
        modified_header: timestamp,
        trashed: items[i].trashed);
    return items[i];
  }

  @override
  Future<Item> updateItemGloballyPinned(String id, int pin) async {
    Response? response =
        await netClient.put('/api/item/$id?pin_globally=$pin', "");
    if (!response.isSuccessStatusCode()) throw 'Error updating item gl. pinned';
    int timestamp = int.parse(response.body);
    int i = items.indexWhere((i) => i.id == id);
    items[i] = items[i].copyWith(
        pinned_globally: pin != 0,
        modified_header: timestamp,
        trashed: items[i].trashed);
    return items[i];
  }

  @override
  Future<List<Item>> updateItemPositions(ItemPositionData ipd) async {
    Response? response =
        await netClient.put('/api/items/position', jsonEncode(ipd));
    if (!response.isSuccessStatusCode()) throw 'Error updating item positions';
    int timestamp = int.parse(response.body);
    for (int i = 0; i < ipd.itemIds.length; i++) {
      int idx = items.indexWhere((item) => item.id == ipd.itemIds[i]);
      items[idx] = items[idx].copyWith(
          position: ipd.itemPositions[i],
          modified_header: timestamp,
          trashed: items[i].trashed);
    }
    return items.where((i) => ipd.itemIds.any((id) => id == i.id)).toList();
  }

  @override
  Future<bool> delete(String id) async {
    Response? response = await netClient.delete('/api/item/$id');
    if (!response.isSuccessStatusCode()) throw 'Error deleteing item';
    items.removeWhere((element) => element.id == id);
    return true;
  }

  @override
  Future<bool> deleteItems(List<String> ids) async {
    Response? response = await netClient.delete('/api/items', jsonEncode(ids));
    if (!response.isSuccessStatusCode()) {
      throw 'Error deleteing items';
    }
    items.removeWhere((element) => ids.any((id) => element.id == id));
    return true;
  }
}
