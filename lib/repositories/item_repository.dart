// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:easynotes/config/locator.dart';
import 'package:easynotes/extensions/http_client_ext.dart';
import 'package:easynotes/models/item.dart';
import 'package:easynotes/services/crypto_service.dart';
import 'package:http/http.dart';

import '../models/item_header.dart';
import '../services/network_provider.dart';
import 'preference_repository.dart';

enum ItemUpdateAction { none, insert, update, updateHeaderOnly }

abstract class ItemRepository {
  Item getRootOf(Item item);
  Future<List<Item>> setItems(List<Item> items);
  List<Item> getItemAndChildren(String id);
  List<Item> getItems();
  Future<List<Item>> fetchItems();
  Future<List<Item>> fetchUntrashedItems();
  Future<List<Item>> fetchTrashedItems();
  Future<List<Item>> fetchRootItems();
  Future<List<Item>> fetchItemsByRootParentId(String? rootId);
  Future<Item> insertOrUpdateItem(Item item, ItemUpdateAction action);
  Future<List<Item>> insertOrUpdateItems(List<Item> items);
  Future<Item> updateItemHeader(ItemHeader header);
  Future<Item> updateItemParent(List<String> ids, String? parent_id,
      [bool untrash = false]);
  Future<Item> updateItemTrashed(List<String> ids, int? trashed);
  Future<Item> updateItemPinned(String id, int pin);
  Future<Item> updateItemGloballyPinned(String id, int pin);
  Future<List<Item>> updateItemPositions(List<String> itemIds);
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

  Map<String, Item> items = {};

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

  @override
  Item getRootOf(Item item) {
    Item rootCandidate = item;
    Item? parent = items[item.parent_id];
    while (parent != null) {
      rootCandidate = parent;
      parent = items[parent.parent_id];
    }
    return rootCandidate;
  }

  // This function is used when initially getting the items from the auth_bloc
  // since they are already returned upon logging in
  @override
  Future<List<Item>> setItems(List<Item> items) async {
    items = await cryptoService.decryptItems(items);
    return items;
  }

  @override
  List<Item> getItems() {
    return items.values.toList();
  }

  @override
  Future<List<Item>> fetchItems() async {
    Response response = await netClient.get('/api/items');
    if (!response.isSuccessStatusCode()) throw 'Unable to fetch data';
    List<Item> encryptedItems = (jsonDecode(response.body) as List)
        .map((i) => Item.fromMap(i))
        .toList();
    final decrypted = await cryptoService.decryptItems(encryptedItems);
    for (var i in decrypted) {
      items[i.id] = i;
    }
    return getItems();
  }

  @override
  Future<List<Item>> fetchUntrashedItems() async {
    Response response = await netClient.get('/api/items?trashed=false');
    if (!response.isSuccessStatusCode()) throw 'Unable to fetch data';
    List<Item> encryptedItems = (jsonDecode(response.body) as List)
        .map((i) => Item.fromMap(i))
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
        .map((i) => Item.fromMap(i))
        .toList();
    final trashedItems = await cryptoService.decryptItems(encryptedItems);
    //items.removeWhere((i) => i.trashed != null);
    //items.addAll(trashedItems);
    return trashedItems;
  }

  @override
  Future<List<Item>> fetchRootItems() async {
    Response response = await netClient.get('/api/items/roots');
    if (!response.isSuccessStatusCode()) throw 'Unable to fetch data';
    List<Item> encryptedItems = (jsonDecode(response.body) as List)
        .map((i) => Item.fromMap(i))
        .toList();
    items.removeWhere((key, value) => value.parent_id == null);
    final rootItems = await cryptoService.decryptItems(encryptedItems);
    for (var i in rootItems) {
      items[i.id] = i;
    }
    return rootItems;
  }

  @override
  Future<List<Item>> fetchItemsByRootParentId(String? id) async {
    Response response = await netClient.post(
        '/api/items${id == null ? '' : '?parent_id=$id'}', "");
    if (!response.isSuccessStatusCode()) throw 'Unable to fetch data';
    List<Item> encryptedItems = (jsonDecode(response.body) as List)
        .map((i) => Item.fromMap(i))
        .toList();
    items.removeWhere((key, value) => getRootOf(value).id == id);
    final rootItems = await cryptoService.decryptItems(encryptedItems);
    for (var i in rootItems) {
      items[i.id] = i;
    }
    return rootItems;
  }

  @override
  Future<Item> insertOrUpdateItem(Item item, ItemUpdateAction action) async {
    Item encrypted = await cryptoService.encryptItem(item);
    Response? response =
        await netClient.post('/api/item', jsonEncode(encrypted));
    if (!response.isSuccessStatusCode()) throw 'Error saving item';
    String newId = response.body;
    items.removeWhere((key, value) => key == item.id);
    Item updated = item.copyWith(id: newId, trashed: item.trashed);
    items[newId] = updated;
    return updated;
  }

  @override
  Future<List<Item>> insertOrUpdateItems(List<Item> items) async {
    List<Item> encryptedItems = await cryptoService.encryptItems(items);
    Response? response =
        await netClient.post('/api/items', jsonEncode(encryptedItems));
    if (!response.isSuccessStatusCode()) throw 'Error saving item';
    this.items.removeWhere((key, value) => items.any((j) => j.id == key));
    for (var i in items) {
      this.items[i.id] = i;
    }
    return await fetchItems();
  }

  @override
  Future<Item> updateItemHeader(ItemHeader header) async {
    Response? response =
        await netClient.put('/api/item/header', jsonEncode(header));
    if (!response.isSuccessStatusCode()) throw 'Error updating item header';
    items[header.id] = items[header.id]!.copyWithHeader(header);
    return items[header.id]!;
  }

  @override
  Future<Item> updateItemParent(List<String> ids, String? parent_id,
      [bool untrash = false]) async {
    String id = ids[0];
    Response? response = await netClient.put(
        '/api/item/$id/parent?parent_id=$parent_id${untrash == true ? '&untrash=$untrash' : ''}',
        jsonEncode(ids));
    if (!response.isSuccessStatusCode()) throw 'Error updating item parent';
    int time = int.parse(response.body);
    items[id] = items[id]!.copyWith(
        parent_id: parent_id,
        trashed: untrash ? null : items[id]!.trashed,
        modified_header: time);
    if (untrash == true) {
      for (String idd in ids) {
        items[idd] = items[idd]!.copyWith(trashed: null, modified_header: time);
      }
    }
    return items[id]!;
  }

  @override
  Future<Item> updateItemTrashed(List<String> ids, int? trashed) async {
    String id = ids[0];
    Response? response = await netClient.put(
        '/api/item/$id/trashed?trashed=$trashed', jsonEncode(ids));
    if (!response.isSuccessStatusCode()) throw 'Error updating item trashed';
    int timestamp = int.parse(response.body);
    for (String i in ids) {
      items[i] =
          items[i]!.copyWith(trashed: trashed, modified_header: timestamp);
    }
    return items[id]!;
  }

  @override
  Future<Item> updateItemPinned(String id, int pin) async {
    Response? response =
        await netClient.put('/api/item/$id/pinned?pin=$pin', "");
    if (!response.isSuccessStatusCode()) throw 'Error updating item pinned';
    int timestamp = int.parse(response.body);
    items[id] = items[id]!.copyWith(
        pinned: pin != 0,
        trashed: items[id]!.trashed,
        modified_header: timestamp);
    return items[id]!;
  }

  @override
  Future<Item> updateItemGloballyPinned(String id, int pin) async {
    Response? response = await netClient.put(
        '/api/item/$id/globallypinned?pin_globally=$pin', "");
    if (!response.isSuccessStatusCode()) throw 'Error updating item gl. pinned';
    int timestamp = int.parse(response.body);
    items[id] = items[id]!.copyWith(
        pinned_globally: pin != 0,
        trashed: items[id]!.trashed,
        modified_header: timestamp);
    return items[id]!;
  }

  @override
  Future<List<Item>> updateItemPositions(List<String> itemIds) async {
    Response? response =
        await netClient.put('/api/items/position', jsonEncode(itemIds));
    if (!response.isSuccessStatusCode()) throw 'Error updating item positions';
    int timestamp = int.parse(response.body);
    for (int i = 0; i < itemIds.length; i++) {
      final id = itemIds[i];
      items[id] = items[id]!.copyWith(
          position: i, modified_header: timestamp, trashed: items[id]!.trashed);
    }
    return items.values.where((i) => itemIds.any((id) => id == i.id)).toList();
  }

  @override
  Future<bool> delete(String id) async {
    Response? response = await netClient.delete('/api/item/$id');
    if (!response.isSuccessStatusCode()) throw 'Error deleteing item';
    items.removeWhere((key, value) => key == id);
    return true;
  }

  @override
  Future<bool> deleteItems(List<String> ids) async {
    Response? response = await netClient.delete('/api/items', jsonEncode(ids));
    if (!response.isSuccessStatusCode()) throw 'Error deleteing items';
    items.removeWhere((key, value) => ids.any((i) => key == i));
    return true;
  }

  @override
  List<Item> getItemAndChildren(String id) {
    Item root = items[id]!;
    Iterable<Item> children = items.values.where((i) => i.parent_id == id);
    return [root, ...children];
  }
}
