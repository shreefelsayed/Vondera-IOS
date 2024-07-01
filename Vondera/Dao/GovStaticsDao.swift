//
//  GovStaticsDao.swift
//  Vondera
//
//  Created by Shreif El Sayed on 20/06/2023.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class GovStaticsDao {
    var collection:CollectionReference
    
    init(storeId:String) {
        self.collection = Firestore.firestore().collection("stores").document(storeId).collection("govStatics")
    }
    
    func getStatics() async throws -> [GovStatics] {
        return try await collection
            .order(by: "count", descending: true)
            .whereField("count", isGreaterThan: 0)
            .limit(to: 10)
            .getDocuments(as: GovStatics.self)
        
    }
}
