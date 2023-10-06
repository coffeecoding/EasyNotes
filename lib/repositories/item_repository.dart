// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:easynotes/config/locator.dart';
import 'package:easynotes/config/messages.dart';
import 'package:easynotes/extensions/http_client_ext.dart';
import 'package:easynotes/models/models.dart';
import 'package:easynotes/services/crypto_service.dart';
import 'package:http/http.dart';

import '../services/network_provider.dart';
import 'abstract_item_repository.dart';
import 'preference_repository.dart';

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
  void reset() {
    items.clear();
    netClient = locator.get<NetworkProvider>();
    cryptoService = locator.get<CryptoService>();
    prefsRepo = locator.get<PreferenceRepository>();
  }

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
  Future<OPResult<List<Item>>> fetchItems() async {
    Response response = await netClient.get('/api/items');
    if (!response.isSuccessStatusCode()) {
      return OPResult.err(buildErrorMsgs(
          ErrorType.network, 'fetchItems', [], response.fullText()));
    }
    try {
      List<Item> encryptedItems = (jsonDecode(response.body) as List)
          .map((i) => Item.fromMap(i))
          .toList();
      final decrypted = await cryptoService.decryptItems(encryptedItems);
      for (var i in decrypted) {
        items[i.id] = i;
      }
      return OPResult(getItems());
    } catch (e) {
      return OPResult.err(
          buildErrorMsgs(ErrorType.client, 'fetchItems', [], e.toString()));
    }
  }

  @override
  Future<OPResult<List<Item>>> fetchUntrashedItems() async {
    Response response = await netClient.get('/api/items?trashed=false');
    if (!response.isSuccessStatusCode()) {
      return OPResult.err(buildErrorMsgs(
          ErrorType.network, 'fetchUntrashedItems', [], response.fullText()));
    }
    try {
      List<Item> encryptedItems = (jsonDecode(response.body) as List)
          .map((i) => Item.fromMap(i))
          .toList();
      final untrashedItems = await cryptoService.decryptItems(encryptedItems);
      //items.removeWhere((i) => i.trashed != null);
      //items.addAll(trashedItems);
      return OPResult(untrashedItems);
    } catch (e) {
      return OPResult.err(buildErrorMsgs(
          ErrorType.client, 'fetchUntrashedItems', [], e.toString()));
    }
  }

  @override
  Future<OPResult<List<Item>>> fetchTrashedItems() async {
    Response response = await netClient.get('/api/items?trashed=asdf');
    if (!response.isSuccessStatusCode()) {
      return OPResult.err(buildErrorMsgs(
          ErrorType.network, 'fetchTrashedItems', [], response.fullText()));
    }
    try {
      List<Item> encryptedItems = (jsonDecode(response.body) as List)
          .map((i) => Item.fromMap(i))
          .toList();
      final trashedItems = await cryptoService.decryptItems(encryptedItems);
      //items.removeWhere((i) => i.trashed != null);
      //items.addAll(trashedItems);
      return OPResult(trashedItems);
    } catch (e) {
      return OPResult.err(buildErrorMsgs(
          ErrorType.client, 'fetchTrashedItems', [], e.toString()));
    }
  }

  @override
  Future<OPResult<List<Item>>> fetchRootItems() async {
    Response response = await netClient.get('/api/items/roots');

    if (!response.isSuccessStatusCode()) {
      return OPResult.err(buildErrorMsgs(
          ErrorType.network, 'fetchRootItems', [], response.fullText()));
    }
    try {
      List<Item> encryptedItems = (jsonDecode(response.body) as List)
          .map((i) => Item.fromMap(i))
          .toList();
      items.removeWhere((key, value) => value.parent_id == null);
      final rootItems = await cryptoService.decryptItems(encryptedItems);
      for (var i in rootItems) {
        items[i.id] = i;
      }
      return OPResult(rootItems);
    } catch (e) {
      return OPResult.err(
          buildErrorMsgs(ErrorType.client, 'fetchRootItems', [], e.toString()));
    }
  }

  @override
  Future<OPResult<List<Item>>> fetchItemsByRootParentId(String? id) async {
    Response response = await netClient.post(
        '/api/items${id == null ? '' : '?parent_id=$id'}', "");
    if (!response.isSuccessStatusCode()) {
      return OPResult.err(buildErrorMsgs(ErrorType.network,
          'fetchItemsByRootParentId', [id], response.fullText()));
    }
    try {
      List<Item> encryptedItems = (jsonDecode(response.body) as List)
          .map((i) => Item.fromMap(i))
          .toList();
      items.removeWhere((key, value) => getRootOf(value).id == id);
      final rootItems = await cryptoService.decryptItems(encryptedItems);
      for (var i in rootItems) {
        items[i.id] = i;
      }
      return OPResult(rootItems);
    } catch (e) {
      return OPResult.err(buildErrorMsgs(
          ErrorType.client, 'fetchItemsByRootParentId', [id], e.toString()));
    }
  }

  @override
  Future<OPResult<Item>> insertOrUpdateItem(
      Item item, ItemUpdateAction action) async {
    Item encrypted = await cryptoService.encryptItem(item);
    Response? response = await netClient.post('/api/item', encrypted.toJson());
    if (!response.isSuccessStatusCode()) {
      return OPResult.err(buildErrorMsgs(ErrorType.network,
          'insertOrUpdateItem', [item, action], response.fullText()));
    }
    try {
      String newId = response.body;
      // items.removeWhere((key, value) => key == item.id);
      Item updated = item.copyWith(id: newId, trashed: item.trashed);
      items[newId] = updated;
      return OPResult(updated);
    } catch (e) {
      return OPResult.err(buildErrorMsgs(ErrorType.client, 'insertOrUpdateItem',
          [item, action], e.toString()));
    }
  }

  @override
  Future<OPResult<List<Item>>> insertOrUpdateItems(List<Item> items) async {
    List<Item> encryptedItems = await cryptoService.encryptItems(items);
    Response? response =
        await netClient.post('/api/items', jsonEncode(encryptedItems));
    if (!response.isSuccessStatusCode()) {
      return OPResult.err(buildErrorMsgs(
          ErrorType.network,
          'insertOrUpdateItems',
          ['${items.length} items'],
          response.fullText()));
    }
    try {
      this.items.removeWhere((key, value) => items.any((j) => j.id == key));
      for (var i in items) {
        this.items[i.id] = i;
      }
      return await fetchItems();
    } catch (e) {
      return OPResult.err(buildErrorMsgs(ErrorType.client,
          'insertOrUpdateItems', ['${items.length} items'], e.toString()));
    }
  }

  @override
  Future<OPResult<Item>> updateItemHeader(ItemHeader header) async {
    Response? response =
        await netClient.put('/api/item/header', header.toJson());
    if (!response.isSuccessStatusCode()) {
      return OPResult.err(buildErrorMsgs(ErrorType.network, 'updateItemHeader',
          [header], response.fullText()));
    }
    try {
      items[header.id] = items[header.id]!.copyWithHeader(header);
      return OPResult(items[header.id]!);
    } catch (e) {
      return OPResult.err(buildErrorMsgs(
          ErrorType.client, 'updateItemHeader', [header], e.toString()));
    }
  }

  @override
  Future<OPResult<Item>> updateItemParent(List<String> ids, String? parent_id,
      [bool untrash = false]) async {
    String id = ids[0];
    Response? response = await netClient.put(
        '/api/item/$id/parent?parent_id=$parent_id${untrash == true ? '&untrash=$untrash' : ''}',
        jsonEncode(ids));
    if (!response.isSuccessStatusCode()) {
      return OPResult.err(buildErrorMsgs(ErrorType.network, 'updateItemParent',
          ['ids=$ids', parent_id, untrash], response.fullText()));
    }
    try {
      int time = int.parse(response.body);
      items[id] = items[id]!.copyWith(
          parent_id: parent_id,
          trashed: untrash ? null : items[id]!.trashed,
          modified_header: time);
      if (untrash == true) {
        for (String idd in ids) {
          items[idd] =
              items[idd]!.copyWith(trashed: null, modified_header: time);
        }
      }
      return OPResult(items[id]!);
    } catch (e) {
      return OPResult.err(buildErrorMsgs(ErrorType.client, 'updateItemParent',
          ['ids=$ids', parent_id, untrash], e.toString()));
    }
  }

  @override
  Future<OPResult<Item>> updateItemTrashed(
      List<String> ids, int? trashed) async {
    String id = ids[0];
    Response? response = await netClient.put(
        '/api/item/$id/trashed?trashed=$trashed', jsonEncode(ids));
    if (!response.isSuccessStatusCode()) {
      return OPResult.err(buildErrorMsgs(ErrorType.network, 'updateItemTrashed',
          ['ids=$ids', trashed], response.fullText()));
    }
    try {
      int timestamp = int.parse(response.body);
      for (String i in ids) {
        items[i] =
            items[i]!.copyWith(trashed: trashed, modified_header: timestamp);
      }
      return OPResult(items[id]!);
    } catch (e) {
      return OPResult.err(buildErrorMsgs(ErrorType.client, 'updateItemTrashed',
          ['ids=$ids', trashed], e.toString()));
    }
  }

  @override
  Future<OPResult<Item>> updateItemPinned(String id, int pin) async {
    Response? response =
        await netClient.put('/api/item/$id/pinned?pin=$pin', "");
    if (!response.isSuccessStatusCode()) {
      return OPResult.err(buildErrorMsgs(ErrorType.network, 'updateItemPinned',
          [id, pin], response.fullText()));
    }
    try {
      int timestamp = int.parse(response.body);
      items[id] = items[id]!.copyWith(
          pinned: pin != 0,
          trashed: items[id]!.trashed,
          modified_header: timestamp);
      return OPResult(items[id]!);
    } catch (e) {
      return OPResult.err(buildErrorMsgs(
          ErrorType.client, 'updateItemPinned', [id, pin], e.toString()));
    }
  }

  @override
  Future<OPResult<Item>> updateItemGloballyPinned(String id, int pin) async {
    Response? response = await netClient.put(
        '/api/item/$id/globallypinned?pin_globally=$pin', "");
    if (!response.isSuccessStatusCode()) {
      return OPResult.err(buildErrorMsgs(ErrorType.network,
          'updateItemGloballyPinned', [id, pin], response.fullText()));
    }
    try {
      int timestamp = int.parse(response.body);
      items[id] = items[id]!.copyWith(
          pinned_globally: pin != 0,
          trashed: items[id]!.trashed,
          modified_header: timestamp);
      return OPResult(items[id]!);
    } catch (e) {
      return OPResult.err(buildErrorMsgs(ErrorType.client,
          'updateItemGloballyPinned', [id, pin], e.toString()));
    }
  }

  @override
  Future<OPResult<List<Item>>> updateItemPositions(List<String> itemIds) async {
    Response? response =
        await netClient.put('/api/items/position', jsonEncode(itemIds));
    if (!response.isSuccessStatusCode()) {
      return OPResult.err(buildErrorMsgs(ErrorType.network,
          'updateItemPositions', ['ids=$itemIds'], response.fullText()));
    }
    try {
      int timestamp = int.parse(response.body);
      for (int i = 0; i < itemIds.length; i++) {
        final id = itemIds[i];
        items[id] = items[id]!.copyWith(
            position: i,
            modified_header: timestamp,
            trashed: items[id]!.trashed);
      }
      return OPResult(
          items.values.where((i) => itemIds.any((id) => id == i.id)).toList());
    } catch (e) {
      return OPResult.err(buildErrorMsgs(ErrorType.client,
          'updateItemPositions', ['ids=$itemIds'], e.toString()));
    }
  }

  @override
  Future<OPResult<bool>> delete(String id) async {
    Response? response = await netClient.delete('/api/item/$id');
    if (!response.isSuccessStatusCode()) {
      return OPResult.err(buildErrorMsgs(
          ErrorType.network, 'delete', [id], response.fullText()));
    }
    try {
      items.removeWhere((key, value) => key == id);
      return OPResult(true);
    } catch (e) {
      return OPResult.err(
          buildErrorMsgs(ErrorType.client, 'delete', [id], e.toString()));
    }
  }

  @override
  Future<OPResult<bool>> deleteItems(List<String> ids) async {
    Response? response = await netClient.delete('/api/items', jsonEncode(ids));
    if (!response.isSuccessStatusCode()) {
      return OPResult.err(buildErrorMsgs(
          ErrorType.network, 'deleteItems', ['ids=$ids'], response.fullText()));
    }
    try {
      items.removeWhere((key, value) => ids.any((i) => key == i));
      return OPResult(true);
    } catch (e) {
      return OPResult.err(buildErrorMsgs(
          ErrorType.client, 'deleteItems', ['ids=$ids'], e.toString()));
    }
  }

  @override
  List<Item> getItemAndChildren(String id) {
    Item root = items[id]!;
    Iterable<Item> children = items.values.where((i) => i.parent_id == id);
    return [root, ...children];
  }
}
