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
        print("Searchig for \(text)")
        let query = collection
            .order(by: "description", descending: true)
            .start(at: [search])
            .end(at: ["\(search)\u{f8ff}"])  // Pass the value as an array
            .limit(to: pageSize)
        
        let docs = try await query.getDocuments()
        return convertToList(snapShot: docs)
    }
    
    func getBetweenDate(from:Date, to:Date) async throws -> [Expense] {
        return convertToList(snapShot: try await collection
            .order(by: "date", descending: true)
            .whereField("date", isGreaterThanOrEqualTo: from)
            .whereField("date", isLessThanOrEqualTo: to)
            .getDocuments()
        )
    }
    
    func getExpanses(lastSnapShot:DocumentSnapshot?) async throws -> ([Expense], QueryDocumentSnapshot?) {
        var query:Query = collection
            .order(by: "date", descending: true)
        
        if lastSnapShot != nil {
            query = query.start(afterDocument: lastSnapShot!)
        }
        
        query.limit(to: pageSize)
        let docs = try await query.getDocuments()
        return (convertToList(snapShot: docs), docs.documents.last)
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
    
    func convertToList(snapShot:QuerySnapshot) -> [Expense] {
        let arr = snapShot.documents.compactMap{doc -> Expense? in
            return try! doc.data(as: Expense.self)
        }
        
        return arr
    }
}
