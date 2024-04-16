//
//  PlanDao.swift
//  Vondera
//
//  Created by Shreif El Sayed on 31/08/2023.
//

import Foundation
import FirebaseFirestoreSwift
import FirebaseFirestore

class PlanDao {
    var collection:CollectionReference = Firestore.firestore().collection("appPlans")
    
    func getPaid() async throws -> [PlanInfo] {
        return try await collection
            .whereField("id", isNotEqualTo: "free")
            .getDocuments(as: PlanInfo.self)
    }
}
