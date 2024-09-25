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
    
    func getOnDemandPlan() -> PlanInfo {
        return PlanInfo(id: "OnDemand",
                        name: "On Demand",
                        desc: "Unlimited orders with only 0.5 LE for each order !",
                        planLevel: 3,
                        planFeatures: PlanFeatures(
                            currentOrders: 0,
                            maxOrders: 0,
                            website: true,
                            payments: true),
                        planInfoPrices: [])
    }
}
