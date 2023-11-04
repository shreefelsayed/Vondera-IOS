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
    
    func getCart()  -> [SavedItems] {
        let myUser = UserInformation.shared.getUser()
        
        if let encodedData = UserDefaults.standard.data(forKey: "\(myUser?.id ?? "") - \(CART_KEY)") {
            if let savedItemsList = try? decoder.decode([SavedItems].self, from: encodedData) {
                return savedItemsList
            }
        }
        
        return []
    }
    
    func saveCart(listCart: [SavedItems]) {
        let myUser = UserInformation.shared.getUser()
        if let encodedData = try? encoder.encode(listCart) {
            UserDefaults.standard.set(encodedData, forKey: "\(myUser?.id ?? "") - \(CART_KEY)")
        }
    }
    
    func clearCart() {
        saveCart(listCart: [])
    }
    
    func removeItemFromCart(randomId: String, hashMap: [String: String]) {
        var listItems = getCart()
        for (index, savedItems) in listItems.enumerated() {
            if savedItems.randomId == randomId {
                if areHashmapsEqual(savedItems.hashMap, hashMap) {
                    listItems.remove(at: index)
                    saveCart(listCart: listItems)
                    break
                }
            }
        }
    }
    
    func isSavedItemInCart(randomId: String, hashMap: [String: String])  -> Bool {
        let listItems = getCart()
        for savedItems in listItems {
            if savedItems.productId == randomId && areHashmapsEqual(savedItems.hashMap, hashMap) {
                return true
            }
        }
        return false
    }
    
    func getSavedItem(productId: String, hashMap: [String: String])  -> SavedItems? {
        let listItems = getCart()
        for savedItems in listItems {
            if savedItems.productId == productId && areHashmapsEqual(savedItems.hashMap, hashMap) {
                return savedItems
            }
        }
        return nil
    }
    
    func addItem(product:StoreProduct, options: [String:String]) {
        let savedItem = SavedItems(randomId: CartManager.generatePIN(), productId: product.id, hashMap: options)
        
        addItem(savedItems: savedItem)
    }
    
    private func addItem(savedItems: SavedItems)  {
        if var currentSavedItem = getSavedItem(productId: savedItems.productId, hashMap: savedItems.hashMap) {
            currentSavedItem.quantity = currentSavedItem.quantity + savedItems.quantity
            removeItemFromCart(randomId: currentSavedItem.randomId, hashMap: savedItems.hashMap)
            addItem(savedItems: currentSavedItem)
            return
        }
        
        var listItems =  getCart()
        listItems.append(savedItems)
        saveCart(listCart: listItems)
    }
    
    private func areHashmapsEqual(_ first: [String: String], _ second: [String: String]) -> Bool {
        return first == second
    }

    
    static func generatePIN() -> String {
        let number = Int.random(in: 0...99999999)
        return String(format: "%08d", number)
    }
}
