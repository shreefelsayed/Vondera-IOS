//
//  OrdersDao.swift
//  Vondera
//
//  Created by Shreif El Sayed on 01/06/2023.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class OrdersDao {
    var collection:CollectionReference
    var pageSize = 25
    
    
    init(storeId:String) {
        self.collection = Firestore.firestore().collection("stores").document(storeId).collection("orders")
    }
    
    
    func isExist(id:String) async throws -> Bool {
        let doc = try await collection.document(id).getDocument()
        return doc.exists
    }
    
    func search(search:String, field:String = "name", lastSnapShot:DocumentSnapshot?) async throws -> ([Order], QueryDocumentSnapshot?) {
        
        var query:Query = collection
            .order(by: field, descending: false)
            .start(at: [search])
            .end(at: ["\(search)\u{f8ff}"])  // Pass the value as an array
        
        if lastSnapShot != nil {
            query = query.start(afterDocument: lastSnapShot!)
        }
        
        query.limit(to: pageSize)
        
        let docs = try await query.getDocuments()
        return (convertToList(snapShot: docs), docs.documents.last)
        
    }
    
    func getClientOrders(id:String) async throws -> [Order] {
        return convertToList(snapShot: try await collection
            .whereField("phone", isEqualTo: id)
            .order(by: "date", descending: true)
            .getDocuments())
    }
    
    func getDeleted(lastSnapShot:DocumentSnapshot?) async throws -> ([Order], QueryDocumentSnapshot?) {
        var query:Query = collection
            .whereField("statue", isEqualTo: "Deleted")
            .order(by: "date", descending: true)
            .limit(to: pageSize)
        
        if lastSnapShot != nil {
            query = query.start(afterDocument: lastSnapShot!)
        }
        
        let docs = try await query.getDocuments()
        return (convertToList(snapShot: docs), docs.documents.last)
    }
    
    func getAll(lastSnapShot:DocumentSnapshot?) async throws -> ([Order], QueryDocumentSnapshot?) {
        var query:Query = collection
            .order(by: "date", descending: true)
            .limit(to: pageSize)
        
        if lastSnapShot != nil {
            query = query.start(afterDocument: lastSnapShot!)
        }
        
        let docs = try await query.getDocuments()
        return (convertToList(snapShot: docs), docs.documents.last)
    }
    
    func getCouriersFinished(id:String, lastSnapShot:DocumentSnapshot?) async throws -> ([Order], QueryDocumentSnapshot?) {
        var query:Query = collection
            .order(by: "dateDelivered", descending: true)
            .whereField("courierId", isEqualTo: id)
            .limit(to: pageSize)
        
        if lastSnapShot != nil {
            query = query.start(afterDocument: lastSnapShot!)
        }
        
        let docs = try await query.getDocuments()
        return (convertToList(snapShot: docs), docs.documents.last)
    }
    
    
    
    func getUserOrders(id:String, lastSnapShot:DocumentSnapshot?) async throws -> ([Order], QueryDocumentSnapshot?) {
        var query:Query = collection
            .whereField("addBy", isEqualTo: id)
            .order(by: "date", descending: true)
            .limit(to: pageSize)
        
        if lastSnapShot != nil {
            query = query.start(afterDocument: lastSnapShot!)
        }
        
        let docs = try await query.getDocuments()
        return (convertToList(snapShot: docs), docs.documents.last)
    }
    
    func getPendingCouriersOrder(id:String)async throws -> [Order] {
        do {
            return convertToList(snapShot: try await collection
                .whereField("courierId", isEqualTo: id)
                .whereField("statue", isEqualTo: "Out For Delivery")
                .order(by: "dateShipping", descending: true)
                .getDocuments())
        }
    }
    
    func getOrder(id: String, completion: @escaping (Order?, Bool) -> Void) async throws {
        do {
            let document = collection.document(id)
            let docSnapshot = try await document.getDocument()
            
            let isHere = docSnapshot.exists
            if isHere {
                let order = try? docSnapshot.data(as: Order.self)
                completion(order, isHere)
            } else {
                completion(nil, isHere)
            }
        } catch {
            completion(nil, false)
            throw error
        }
    }
    
    func update(id:String, hashMap:[String:Any]) async throws {
        return try await collection.document(id).updateData(hashMap)
    }
    
    func addUpdate(id:String, update:Updates) async throws {
        let encoded: [String: Any]
        encoded = try Firestore.Encoder().encode(update)
        try await collection.document(id).updateData(["listUpdates":FieldValue.arrayUnion([encoded])])
    }
    
    func add(order:Order) async throws {
        return try collection.document(order.id).setData(from: order)
    }
    
    // --> Get orders by statue
    func getOrdersByStatue(statue:String) async throws -> [Order] {
        return convertToList(snapShot: try await collection.whereField("statue", isEqualTo: statue)
            .order(by: "date", descending: true)
            .getDocuments())
        
    }
    
    func convertToList(snapShot:QuerySnapshot) -> [Order] {
        let arr = snapShot.documents.compactMap{doc -> Order? in
            //print("Order \(doc.documentID)")
            return try! doc.data(as: Order.self)
        }
        
        return arr
    }
}
