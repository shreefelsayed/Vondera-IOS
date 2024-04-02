//
//  CategoryDao.swift
//  Vondera
//
//  Created by Shreif El Sayed on 22/06/2023.
//

import Foundation
import FirebaseFirestoreSwift
import FirebaseFirestore

class VPayoutsDao {
    var collection:CollectionReference
    
    init(storeId:String) {
        self.collection = Firestore.firestore().collection("stores").document(storeId).collection("vPayouts")
    }
    
    
    func getAll(lastSnapshot:DocumentSnapshot?) async throws -> ([VPayout], DocumentSnapshot?) {
        return try await collection
            .order(by: "date", descending: true)
            .limit(to: 20)
            .startAfter(lastDocument: lastSnapshot)
            .getDocumentWithLastSnapshot(as: VPayout.self)
    }
}
