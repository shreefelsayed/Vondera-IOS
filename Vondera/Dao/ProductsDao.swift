//
//  ProductsDao.swift
//  Vondera
//
//  Created by Shreif El Sayed on 01/06/2023.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class ProductsDao {
    var collection:CollectionReference
    let pageSize = 10
    
    init(storeId:String) {
        self.collection = Firestore.firestore().collection("stores").document(storeId).collection("products")
    }
    
    func delete(id:String) async throws {
        return try await collection.document(id).delete()
    }
    
    func create(_ product:StoreProduct) async throws {
        try collection.document(product.id).setData(from: product)
    }
    
    func productExist(id:String) async throws -> Bool {
        let doc = try await collection.document(id).getDocument()
        return doc.exists
    }
    
    func getInStock() async throws -> [StoreProduct] {
        return try await collection
            .whereField("quantity", isGreaterThan: 0)
            .order(by: "quantity", descending: true)
            .getDocuments(as: StoreProduct.self)
    }
    
    func getFeatured() async throws -> [StoreProduct] {
        return try await collection
            .whereField("featured", isEqualTo: true)
            .whereField("visible", isEqualTo: true)
            .order(by: "createDate", descending: true)
            .getDocuments(as: StoreProduct.self)
    }
    
    func getVisible() async throws -> [StoreProduct] {
        return try await collection
            .whereField("visible", isEqualTo: true)
            .getDocuments(as: StoreProduct.self)
    }
    
    func getCategoryRecent(categoryId:String, limit:Int = 5) async throws -> [StoreProduct] {
        return try await collection
            .whereField("categoryId", isEqualTo: categoryId)
            .order(by: "createDate", descending: true)
            .limit(to: limit)
            .getDocuments(as: StoreProduct.self)
    }
    
    func getAlwaysStocked(lastSnapShot:DocumentSnapshot?) async throws -> ([StoreProduct], DocumentSnapshot?) {
        var query:Query = collection
            .order(by: "name", descending: true)
            .whereField("alwaysStocked", isEqualTo: true)
            .limit(to: 500)
        
        if lastSnapShot != nil {
            query = query.start(afterDocument: lastSnapShot!)
        }
                
        let data = try await query.getDocumentWithLastSnapshot(as: StoreProduct.self)
        return (data.items, data.lastDocument)
    }
    
    func getInStock(lastSnapShot:DocumentSnapshot?) async throws -> ([StoreProduct], DocumentSnapshot?) {
        return try await collection
            .whereField("quantity", isGreaterThan: 0)
            .order(by: "quantity", descending: true)
            .startAfter(lastDocument: lastSnapShot)
            .limit(to: 500)
            .getDocumentWithLastSnapshot(as: StoreProduct.self)
    }
    
    func getOutOfStock() async throws -> [StoreProduct] {
        try await collection
            .order(by: "quantity", descending: false)
            .whereField("quantity", isLessThanOrEqualTo: 0)
            .order(by: "quantity", descending: false)
            .getDocuments(as: StoreProduct.self)
    }
    
    func getOutOfStock(lastSnapShot:DocumentSnapshot?) async throws -> ([StoreProduct], DocumentSnapshot?) {
        return try await collection
            .whereField("quantity", isLessThanOrEqualTo: 0)
            .order(by: "quantity", descending: false)
            .startAfter(lastDocument: lastSnapShot)
            .limit(to: 500)
            .getDocumentWithLastSnapshot(as: StoreProduct.self)
    }
    
    func getStockLessThen(almostOut:Int) async throws -> [StoreProduct] {
        return try await collection
            .whereField("quantity", isLessThanOrEqualTo: almostOut)
            .whereField("quantity", isGreaterThan: 0)
            .order(by: "quantity", descending: true)
            .getDocuments(as: StoreProduct.self)
    }
    
    func getStockLessThen(almostOut:Int, lastSnapShot:DocumentSnapshot?) async throws -> ([StoreProduct], DocumentSnapshot?) {
        return try await collection
            .whereField("quantity", isLessThanOrEqualTo: almostOut)
            .whereField("quantity", isGreaterThan: 0)
            .order(by: "quantity", descending: false)
            .startAfter(lastDocument: lastSnapShot)
            .limit(to: 500)
            .getDocumentWithLastSnapshot(as: StoreProduct.self)
    }
    
    func getByCategory(id:String) async throws -> [StoreProduct] {
        return try await collection
            .whereField("categoryId", isEqualTo: id)
            .getDocuments(as: StoreProduct.self)
        
    }
    
    func getAll(sort:String = "name") async throws -> [StoreProduct] {
        return try await collection
            .order(by: sort, descending: true)
            .getDocuments(as: StoreProduct.self)
    }
    
    func addToStock(id:String, q:Double) async throws {
        return try await collection.document(id).updateData(["quantity":  FieldValue.increment(q)])
    }
    
    func detectFromStock(id:String, productInfo:ProductOrderObject) async throws {
        return try await collection.document(id).updateData(["quantity":  FieldValue.increment(Double(productInfo.quantity * -1)),
                                                             "listOrders":FieldValue.arrayUnion([productInfo])])
    }
    
    func update(id:String, hashMap:[String:Any]) async throws {
        return try await collection.document(id).updateData(hashMap)
    }
    
    func getTopSelling(limit:Int = 10) async throws -> [StoreProduct] {
        return  try await collection
            .order(by: "sold", descending: true)
            .whereField("sold", isGreaterThan: 0)
            .limit(to: limit)
            .getDocuments(as: StoreProduct.self)
    }
    
    func getLastOrdered(limit:Int = 10) async throws -> [StoreProduct] {
        return try await collection
            .order(by: "lastOrderDate", descending: true)
            .limit(to: limit)
            .getDocuments(as: StoreProduct.self)
    }
    
    func getMostVieweed(limit:Int = 10) async throws -> [StoreProduct] {
        return  try await collection
            .order(by: "views", descending: true)
            .whereField("views", isGreaterThan: 0)
            .limit(to: limit)
            .getDocuments(as: StoreProduct.self)
    }
    
    func getProduct(id:String) async throws -> StoreProduct? {
        let doc = try await collection.document(id).getDocument()
        if !doc.exists { return nil }
        return try doc.data(as: StoreProduct.self)
    }
    
    func removeOrderItem(orderId:String, productId:String, q:Int) async throws -> Bool {
        let prod = try await getProduct(id: productId)
        if var prod = prod {
            var found = false
            for (index, orderObj) in prod.listOrder!.enumerated() {
                if orderObj.orderId == orderId {
                    prod.listOrder!.remove(at: index)
                    found.toggle()
                    break
                }
            }
            
            if found {
                let hash:[String:Any] = ["listOrder": prod.listOrder!, "quantity": FieldValue.increment(Double(q))]
                try await update(id: productId, hashMap: hash)
                return true
            }
            
            return false
        }
        
        return false
    }
}
