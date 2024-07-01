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
    public static let pageSize:Int = 25
    
    
    init(storeId:String) {
        self.collection = Firestore.firestore().collection("stores").document(storeId).collection("orders")
    }
    
    
    func isExist(id:String) async throws -> Bool {
        let doc = try await collection.document(id).getDocument()
        return doc.exists
    }
    
    func searchByTextWithStatue(search:String, statue:String, lastSnapshot:DocumentSnapshot?) async throws -> (items: [Order], lastDocument: DocumentSnapshot?) {
        
        return try await collection
            .whereField("statue", isEqualTo: statue)
            .order(by: getSearchIndex(query: search), descending: false)
            .start(at: [search])
            .end(at: ["\(search)\u{f8ff}"])
            .startAfter(lastDocument: lastSnapshot)
            .limit(to: OrdersDao.pageSize)
            .getDocumentWithLastSnapshot(as: Order.self)
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
    
    func search(search:String, field:String = "name", lastSnapShot:DocumentSnapshot?) async throws -> ([Order], DocumentSnapshot?) {
        
        return try await collection
            .order(by: field, descending: false)
            .start(at: [search])
            .end(at: ["\(search)\u{f8ff}"])
            .startAfter(lastDocument: lastSnapShot)
            .limit(to: OrdersDao.pageSize)
            .getDocumentWithLastSnapshot(as: Order.self)
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
        return try await collection
            .order(by: "date", descending: true)
            .whereField("date", isGreaterThanOrEqualTo: from)
            .whereField("date", isLessThanOrEqualTo: to)
            .getDocuments(as: Order.self)
    }
    
    func getOrdersByDeliverDate(from:Date, to:Date) async throws -> [Order] {
        return  try await collection
            .order(by: "dateDelivered", descending: true)
            .whereField("dateDelivered", isGreaterThanOrEqualTo: from)
            .whereField("dateDelivered", isLessThanOrEqualTo: to)
            .getDocuments(as: Order.self)
    }
    
    func getClientOrders(id:String) async throws -> [Order] {
        return try await collection
            .whereField("phone", isEqualTo: id)
            .order(by: "date", descending: true)
            .getDocuments(as: Order.self)
    }
    
    func getDeleted(lastSnapShot:DocumentSnapshot?) async throws -> ([Order], DocumentSnapshot?) {
        return try await collection
            .whereField("statue", isEqualTo: "Deleted")
            .order(by: "date", descending: true)
            .limit(to: OrdersDao.pageSize)
            .startAfter(lastDocument: lastSnapShot)
            .getDocumentWithLastSnapshot(as: Order.self)
    }
    
    func getQueryByStatuePagination(statue:String, lastSnapShot:DocumentSnapshot?, sortBy:String = "date", desc:Bool = true, limit:Int = OrdersDao.pageSize)  async throws -> (items:[Order], lastDocument:DocumentSnapshot?) {
        
        return try await collection.whereField("statue", isEqualTo: statue)
            .order(by: sortBy, descending: desc)
            .limit(to: limit)
            .startAfter(lastDocument: lastSnapShot)
            .getDocumentWithLastSnapshot(as: Order.self)
    }
    
    func getAll(lastSnapShot:DocumentSnapshot?) async throws -> ([Order], DocumentSnapshot?) {
        return try await collection
            .order(by: "date", descending: true)
            .limit(to: OrdersDao.pageSize)
            .startAfter(lastDocument: lastSnapShot)
            .getDocumentWithLastSnapshot(as: Order.self)
    }
    
    
    func getMarketPlaceOrders(marketId:String,lastSnapShot:DocumentSnapshot?) async throws -> (items : [Order],lastDocument : DocumentSnapshot?) {
        return try await collection
            .order(by: "date", descending: true)
            .whereField("marketPlaceId", isEqualTo: marketId)
            .limit(to: OrdersDao.pageSize)
            .startAfter(lastDocument: lastSnapShot)
            .getDocumentWithLastSnapshot(as: Order.self)
    }
    
    func getCourierDelivered(id:String, lastSnapShot:DocumentSnapshot?) async throws -> (items : [Order],lastDocument : DocumentSnapshot?) {
        return try await collection
            .order(by: "dateDelivered", descending: true)
            .whereField("courierId", isEqualTo: id)
            .whereField("statue", isEqualTo: "Delivered")
            .limit(to: OrdersDao.pageSize)
            .startAfter(lastDocument: lastSnapShot)
            .getDocumentWithLastSnapshot(as: Order.self)
    }
    
    /// MARK : This query filter the orders based on a lot of variables, you can pass some of them or none of them
    func filterOrders(lastSnapShot:DocumentSnapshot? = nil, isPaginated:Bool = true , sortIndex:String = "date", desc:Bool = true, filterModel:FilterModel?) async throws -> (items : [Order], lastDocument : DocumentSnapshot?) {
        
        var query:Query = collection
        
        if let statue = filterModel?.filterStatue, !statue.isEmpty {
            query = query.whereField("statue", in: statue)
        }
        
        if let govs = filterModel?.filterGovs, !govs.isEmpty {
            query = query.whereField("gov", in: govs)
        }
        
        if let isShipping = filterModel?.filterShipping, !isShipping.isEmpty {
            query = query.whereField("requireDelivery", in: isShipping)
        }
        
        if let marketPlaceId = filterModel?.filterMarkets, !marketPlaceId.isEmpty {
            query = query.whereField("marketPlaceId", in: marketPlaceId)
        }
        
        if let courierId = filterModel?.filterCouriers, !courierId.isEmpty {
            query = query.whereField("courierId", in: courierId)
        }
        
        if let isPaid = filterModel?.filterPaid, !isPaid.isEmpty {
            query = query.whereField("isPaid", in: isPaid)
        }
        
        if let employeeId = filterModel?.filterUsers, !employeeId.isEmpty {
            query = query.whereField("addBy", in: employeeId)
        }
        
        if let minPrice = filterModel?.minPrice, minPrice != 0 {
            query = query.whereField("salesTotal", isLessThanOrEqualTo: minPrice)
        }
        
        if let maxPrice = filterModel?.maxPrice, maxPrice != 0 {
            query = query.whereField("salesTotal", isGreaterThanOrEqualTo: maxPrice)
        }
        
        query = query.order(by: sortIndex, descending: desc)
            .startAfter(lastDocument: lastSnapShot)
            .limit(to: isPaginated ? OrdersDao.pageSize : 1000)
        
        return try await query.getDocumentWithLastSnapshot(as: Order.self)
    }
    
    func getCourierFailed(id:String, lastSnapShot:DocumentSnapshot?) async throws -> (items : [Order],lastDocument : DocumentSnapshot?) {
        return try await collection
            .order(by: "dateDelivered", descending: true)
            .whereField("courierId", isEqualTo: id)
            .whereField("statue", isEqualTo: "Failed")
            .limit(to: OrdersDao.pageSize)
            .startAfter(lastDocument: lastSnapShot)
            .getDocumentWithLastSnapshot(as: Order.self)
    }
    
    
    
    func getUserOrders(id:String, lastSnapShot:DocumentSnapshot?) async throws -> ([Order], DocumentSnapshot?) {
        return try await collection
            .whereField("addBy", isEqualTo: id)
            .order(by: "date", descending: true)
            .limit(to: OrdersDao.pageSize)
            .startAfter(lastDocument: lastSnapShot)
            .getDocumentWithLastSnapshot(as: Order.self)

    }
    
    func getPendingCouriersOrder(id:String) async throws -> [Order] {
        do {
            return try await collection
                .whereField("courierId", isEqualTo: id)
                .whereField("statue", isEqualTo: "Out For Delivery")
                .order(by: "dateShipping", descending: true)
                .getDocuments(as: Order.self)
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
        return try await collection.whereField("statue", isEqualTo: statue)
            .order(by: "date", descending: true)
            .getDocuments(as: Order.self)
        
    }
    
    func getOrdersQueryByStatue(statue:String) -> Query {
        return collection.whereField("statue", isEqualTo: statue)
            .order(by: "date", descending: true)
    }
}
