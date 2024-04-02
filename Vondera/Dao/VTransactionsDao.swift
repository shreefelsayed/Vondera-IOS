//
//  CategoryDao.swift
//  Vondera
//
//  Created by Shreif El Sayed on 22/06/2023.
//

import Foundation
import FirebaseFirestoreSwift
import FirebaseFirestore

class VTransactionsDao {
    var collection:CollectionReference
    
    init(storeId:String) {
        self.collection = Firestore.firestore().collection("stores").document(storeId).collection("vTransactions")
    }
    
    func getTransaction(id:String) async throws -> VTransaction? {
        return try await collection.document(id).getDocument(as: VTransaction.self)
    }
    
    func getAll(lastSnapshot:DocumentSnapshot?) async throws -> ([VTransaction], DocumentSnapshot?) {
        return try await collection
            .order(by: "date", descending: true)
            .limit(to: 20)
            .startAfter(lastDocument: lastSnapshot)
            .getDocumentWithLastSnapshot(as: VTransaction.self)
    }
}
