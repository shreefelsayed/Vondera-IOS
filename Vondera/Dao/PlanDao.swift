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
    var collection:CollectionReference = Firestore.firestore().collection("plans")
    
    func getPaid() async throws -> [Plan] {
        let docs = try await collection
            .order(by: "price", descending: false)
            .whereField("price", isGreaterThan: 0)
            .getDocuments()
        
        return convertToList(snapShot: docs)
    }
    
    
    func convertToList(snapShot:QuerySnapshot) -> [Plan] {
        let arr = snapShot.documents.compactMap{doc -> Plan? in
            return try! doc.data(as: Plan.self)
        }
        
        return arr
    }
}
