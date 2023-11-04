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
    
    func searchByTextWithStatue(search:String, statue:String, lastSnapshot:DocumentSnapshot?) async throws -> (items: [Order], lastDocument: DocumentSnapshot?) {
        
        var query:Query = collection
            .whereField("statue", isEqualTo: statue)
            .order(by: getSearchIndex(query: search), descending: false)
            .start(at: [search])
            .end(at: ["\(search)\u{f8ff}"])
        
        if lastSnapshot != nil {
            query = query.start(afterDocument: lastSnapshot!)
        }
        
        query.limit(to: pageSize)
        
        let docs = try await query.getDocuments()
        return (convertToList(snapShot: docs), docs.documents.last)
    }
    
    func searchByText(query:String, lastSnapshot:DocumentSnapshot?) async throws -> (items: [Order], lastDocument: DocumentSnapshot?) {
        return try await search(search: query, field: getSearchIndex(query: query), lastSnapShot: lastSnapshot)
    }
    
    private func getSearchIndex(query:String) -> String {
        var index = "name"
        
        if query.isPhoneNumber {
            index = "phone"
        } else if query.isNumeric && !query.isPhoneNumber {
            index = "id"
        }
        
        return index
    }
    
    func getOrdersSortedBy(index:String = "date", desc:Bool = true, limit:Int = 5) async throws -> [Order] {
        return try await collection
            .order(by: "statue", descending: true)
            .whereField("statue", isNotEqualTo: "Deleted")
            .order(by: index, descending: desc)
            .limit(to: limit)
            .getDocuments(as: Order.self)
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
    
    func getCourierOrdersByDate(_ id:String, from:Date, to:Date) async throws -> [Order] {
        return try await collection
            .whereField("courierId", isEqualTo: id)
            .order(by: "dateShipping", descending: true)
            .whereField("dateShipping", isGreaterThanOrEqualTo: from)
            .whereField("dateShipping", isLessThanOrEqualTo: to)
            .getDocuments(as: Order.self)
    }
    
    func getMarketPlaceOrdersByDate(_ id:String, from:Date, to:Date) async throws -> [Order] {
        return try await collection
            .whereField("marketPlaceId", isEqualTo: id)
            .order(by: "date", descending: true)
            .whereField("date", isGreaterThanOrEqualTo: from)
            .whereField("date", isLessThanOrEqualTo: to)
            .getDocuments(as: Order.self)
    }
    
    func getEmployeeOrdersByDate(_ id:String, from:Date, to:Date) async throws -> [Order] {
        return try await collection
            .whereField("addBy", isEqualTo: id)
            .order(by: "date", descending: true)
            .whereField("date", isGreaterThanOrEqualTo: from)
            .whereField("date", isLessThanOrEqualTo: to)
            .getDocuments(as: Order.self)
    }
    
    func getOrdersByAddDate(from:Date, to:Date) async throws -> [Order] {
        return convertToList(snapShot: try await collection
            .order(by: "date", descending: true)
            .whereField("date", isGreaterThanOrEqualTo: from)
            .whereField("date", isLessThanOrEqualTo: to)
            .getDocuments())
    }
    
    func getOrdersByDeliverDate(from:Date, to:Date) async throws -> [Order] {
        return convertToList(snapShot: try await collection
            .order(by: "dateDelivered", descending: true)
            .whereField("dateDelivered", isGreaterThanOrEqualTo: from)
            .whereField("dateDelivered", isLessThanOrEqualTo: to)
            .getDocuments())
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
    
    
    func getMarketPlaceOrders(marketId:String,lastSnapShot:DocumentSnapshot?) async throws -> (items : [Order],lastDocument : DocumentSnapshot?) {
        return try await collection
            .order(by: "date", descending: true)
            .whereField("marketPlaceId", isEqualTo: marketId)
            .limit(to: pageSize)
            .startAfter(lastDocument: lastSnapShot)
            .getDocumentWithLastSnapshot(as: Order.self)
    }
    
    func getCouriersFinished(id:String, lastSnapShot:DocumentSnapshot?) async throws -> (items : [Order],lastDocument : DocumentSnapshot?) {
        return try await collection
            .order(by: "dateDelivered", descending: true)
            .whereField("courierId", isEqualTo: id)
            .whereField("statue", in: ["Delivered", "Failed"])
            .limit(to: pageSize)
            .startAfter(lastDocument: lastSnapShot)
            .getDocumentWithLastSnapshot(as: Order.self)
    }
    
    
    
    func getUserOrders(id:String, lastSnapShot:DocumentSnapshot?) async throws -> ([Order], QueryDocumentSnapshot?) {
        let docs = try await collection
            .whereField("addBy", isEqualTo: id)
            .order(by: "date", descending: true)
            .limit(to: pageSize)
            .startAfter(lastDocument: lastSnapShot)
            .getDocuments()

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
    
    func getPendingCouriersOrderCount(id:String) async throws -> Int {
        let count = try await collection
            .whereField("courierId", isEqualTo: id)
            .whereField("statue", isEqualTo: "Out For Delivery")
            .count.getAggregation(source: .server).count
        
        return Int(truncating: count)
    }

    func getOrder(id: String) async throws -> (item : Order, exists : Bool) {
        return try await collection.document(id).getDocument(as: Order.self)
    }
    
    func update(id:String, hashMap:[String:Any]) async throws {
        return try await collection.document(id).updateData(hashMap)
    }
    
    func addUpdate(id:String, update:Updates) async throws {
        let encoded: [String: Any]
        encoded = try Firestore.Encoder().encode(update)
        try await collection.document(id).updateData(["listUpdates":FieldValue.arrayUnion([encoded]), "lastUpdated": Date()])
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
    
    func getOrdersQueryByStatue(statue:String) -> Query {
        return collection.whereField("statue", isEqualTo: statue)
            .order(by: "date", descending: true)
    }
    
    func convertToList(snapShot:QuerySnapshot) -> [Order] {
        let arr = snapShot.documents.compactMap{doc -> Order? in
            //print("Order \(doc.documentID)")
            return try! doc.data(as: Order.self)
        }
        
        return arr
    }
    
    func convertToList(snapShot:[QueryDocumentSnapshot]) -> [Order] {
        let arr = snapShot.compactMap{doc -> Order? in
            //print("Order \(doc.documentID)")
            return try! doc.data(as: Order.self)
        }
        
        return arr
    }
}
