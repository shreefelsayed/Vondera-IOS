//
//  ExpansesDao.swift
//  Vondera
//
//  Created by Shreif El Sayed on 25/06/2023.
//

import Foundation
import FirebaseFirestore

class ExpansesDao {
    var collection:CollectionReference
    let pageSize = 20
    
    init(storeId:String) {
        self.collection = Firestore.firestore().collection("stores").document(storeId).collection("expanses")
    }
    
    func search(text:String) async throws -> [Expense] {
        return try await collection
            .order(by: "description", descending: true)
            .start(at: [search])
            .end(at: ["\(String(describing: search))\u{f8ff}"])  // Pass the value as an array
            .limit(to: pageSize)
            .getDocuments(as: Expense.self)
        
    }
    
    func getBetweenDate(from:Date, to:Date) async throws -> [Expense] {
        return try await collection
            .order(by: "date", descending: true)
            .whereField("date", isGreaterThanOrEqualTo: from)
            .whereField("date", isLessThanOrEqualTo: to)
            .getDocuments(as: Expense.self)
    }
    
    func getExpanses(lastSnapShot:DocumentSnapshot?) async throws -> ([Expense], DocumentSnapshot?) {
        return try await collection
            .order(by: "date", descending: true)
            .startAfter(lastDocument: lastSnapShot)
            .limit(to: pageSize)
            .getDocumentWithLastSnapshot(as: Expense.self)
    }
    
    
    func create(expanses: inout Expense) async throws {
        if expanses.id.isEmpty {
            expanses.id = collection.document().documentID
        }
        
        try collection.document(expanses.id).setData(from: expanses)
    }
    
    func getExpanses(id:String) async throws -> Expense {
        return try await collection.document(id).getDocument(as: Expense.self)
    }
    
    func update(id:String, hashMap:[String:Any]) async throws {
        return try await collection.document(id).updateData(hashMap)
    }
    
    func delete(id:String) async throws {
        return try await collection.document(id).delete()
    }
}
