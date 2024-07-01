//
//  PagesDao.swift
//  Vondera
//
//  Created by Shreif El Sayed on 28/10/2023.
//

import Foundation
import FirebaseFirestore

class AdminTransDao {
    var collection:CollectionReference = Firestore.firestore().collection("transactions")
    
    
    func getTransactions(lastDoc:DocumentSnapshot?) async throws -> ([AdminTransaction], DocumentSnapshot?) {
        return try await collection
            .order(by: "date", descending: true)
            .startAfter(lastDocument: lastDoc)
            .limit(to: 20)
            .getDocumentWithLastSnapshot(as: AdminTransaction.self)
    }
    
    func getTodayTrans() -> Query {
        return  collection
            .order(by: "date", descending: true)
            .whereField("date", isGreaterThanOrEqualTo: Date().startOfDay())
            .whereField("date", isLessThanOrEqualTo: Date().endOfDay())
    }
}

struct AdminTransaction: Codable {
    var uId: String? // User id
    var id: String // Transaction Id
    var mId: String? // Username
    var desc: String? // Description
    var method: String? // Method
    var planId: String? // PlanId
    var date: Date // Date
    var amount: Double // Amount
}
