//
//  ClientsDao.swift
//  Vondera
//
//  Created by Shreif El Sayed on 23/06/2023.
//

import Foundation
import FirebaseFirestore
class ClientsDao {
    var collection:CollectionReference
    let pageSize = 50
    
    init(storeId:String) {
        self.collection = Firestore.firestore().collection("stores").document(storeId).collection("clients")
    }
    
    func getClient(phone:String) async throws -> Client? {
        let doc = try await collection.document(phone).getDocument()
        if doc.exists { return try doc.data(as: Client.self) }
        return nil
    }
    
    func getClientsByData(from:Timestamp, to:Timestamp) async throws -> [Client] {
        return try await collection
            .order(by: "lastOrder", descending: true)
            .whereField("lastOrder", isGreaterThanOrEqualTo: from)
            .whereField("lastOrder", isLessThanOrEqualTo: to)
            .getDocuments(as: Client.self)
    }
    
    func search(search:String, field:String = "name", lastSnapShot:DocumentSnapshot?) async throws -> ([Client], DocumentSnapshot?) {
        return try await collection
            .order(by: field, descending: false)
            .start(at: [search])
            .end(at: ["\(search)\u{f8ff}"])
            .startAfter(lastDocument: lastSnapShot)
            .limit(to: pageSize)
            .getDocumentWithLastSnapshot(as: Client.self)
    }
                                                                                                       
    func getClients(sort:String = "lastOrder", lastSnapShot:DocumentSnapshot?) async throws -> (items: [Client], lastDocument: DocumentSnapshot?) {
        return try await collection
            .order(by: sort, descending: true)
            .limit(to: pageSize)
            .startAfter(lastDocument: lastSnapShot)
            .getDocumentWithLastSnapshot(as: Client.self)
    }
    
    func update(id:String, hashMap:[String:Any]) async throws {
        return try await collection.document(id).updateData(hashMap)
    }
}
