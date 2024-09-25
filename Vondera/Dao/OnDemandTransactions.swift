//
//  OnDemandTransactions.swift
//  Vondera
//
//  Created by Shreif El Sayed on 20/09/2024.
//

import Foundation
import FirebaseFirestoreSwift
import FirebaseFirestore

class OnDemandDao {
    var collection:CollectionReference
    
    init(storeId:String) {
        self.collection = Firestore.firestore().collection("stores").document(storeId).collection("ordersTransactions")
    }
    
    func getTransaction(id:String) async throws -> OnDemandTransactionModel? {
        return try await collection.document(id).getDocument(as: OnDemandTransactionModel.self)
    }
    
    func getAll(lastSnapshot:DocumentSnapshot?) async throws -> ([OnDemandTransactionModel], DocumentSnapshot?) {
        return try await collection
            .order(by: "date", descending: true)
            .limit(to: 20)
            .startAfter(lastDocument: lastSnapshot)
            .getDocumentWithLastSnapshot(as: OnDemandTransactionModel.self)
    }
}
