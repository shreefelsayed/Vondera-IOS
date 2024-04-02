//
//  CategoryManager.swift
//  Vondera
//
//  Created by Shreif El Sayed on 27/09/2023.
//

import Foundation

class CategoryManager {
    
    func getCategoryById(id:Int) -> StoreCategory? {
        return getAll().first(where: {$0.id == id})
    }
    
    func getAll() -> [StoreCategory] {
        var items:[StoreCategory] = []
        
        items.append(StoreCategory(id: 0, drawableId: "btn_mobile", name: "Electronics and Gadgets"))
        items.append(StoreCategory(id: 1, drawableId: "btn_clothes", name: "Apparel and Fashion"))
        items.append(StoreCategory(id: 2, drawableId: "btn_books", name: "Books and Media"))
        items.append(StoreCategory(id: 3, drawableId: "btn_gifts", name: "Gifts and Novelties"))
        items.append(StoreCategory(id: 4, drawableId: "btn_beauty", name: "Beauty and Cosmetics"))
        items.append(StoreCategory(id: 5, drawableId: "btn_sports", name: "Sports and Outdoors"))
        items.append(StoreCategory(id: 6, drawableId: "btn_food", name: "Food and Beverages"))
        items.append(StoreCategory(id: 7, drawableId: "btn_others", name: "Others"))
        return items
    }
}
