//
//  CartManager.swift
//  Vondera
//
//  Created by Shreif El Sayed on 29/06/2023.
//

import Foundation

class CartManager {
    let CART_KEY = "cart"
    let defaults = UserDefaults.standard
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    
    func getCart() async -> [SavedItems] {
        let myUser = await LocalInfo().getLocalUser()

        if let encodedData = UserDefaults.standard.data(forKey: "\(myUser?.id ?? "") - \(CART_KEY)") {
            if let savedItemsList = try? decoder.decode([SavedItems].self, from: encodedData) {
               return savedItemsList
            }
        }
        
        return []
    }
    
    func saveCart(listCart: [SavedItems]) async {
        let myUser = await LocalInfo().getLocalUser()
        if let encodedData = try? encoder.encode(listCart) {
            UserDefaults.standard.set(encodedData, forKey: "\(myUser?.id ?? "") - \(CART_KEY)")
        }
    }
    
    func clearCart() async {
        await saveCart(listCart: [])
    }
    
    func removeItemFromCart(randomId: String, hashMap: [String: String]) async {
        var listItems = await getCart()
        for (index, savedItems) in listItems.enumerated() {
            if savedItems.randomId == randomId {
                if areHashmapsEqual(savedItems.hashMap, hashMap) {
                    listItems.remove(at: index)
                    await saveCart(listCart: listItems)
                    break
                }
            }
        }
    }
    
    func isSavedItemInCart(randomId: String, hashMap: [String: String]) async -> Bool {
        let listItems = await getCart()
        for savedItems in listItems {
            if savedItems.productId == randomId && areHashmapsEqual(savedItems.hashMap, hashMap) {
                return true
            }
        }
        return false
    }
    
     func getSavedItem(productId: String, hashMap: [String: String]) async -> SavedItems? {
        let listItems = await getCart()
        for savedItems in listItems {
            if savedItems.productId == productId && areHashmapsEqual(savedItems.hashMap, hashMap) {
                return savedItems
            }
        }
        return nil
    }
    
     func addItem(savedItems: SavedItems) async {
         if var currentSavedItem = await getSavedItem(productId: savedItems.productId, hashMap: savedItems.hashMap) {
            currentSavedItem.quantity = currentSavedItem.quantity + savedItems.quantity
            await removeItemFromCart(randomId: currentSavedItem.randomId, hashMap: savedItems.hashMap)
            await addItem(savedItems: currentSavedItem)
            return
        }
        
        var listItems = await getCart()
        listItems.append(savedItems)
        await saveCart(listCart: listItems)
    }
    
    private func areHashmapsEqual(_ first: [String: String], _ second: [String: String]) -> Bool {
        return first == second
    }
}
