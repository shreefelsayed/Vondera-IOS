//
//  TipDao.swift
//  Vondera
//
//  Created by Shreif El Sayed on 20/06/2023.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class TipDao {
    var collection = Firestore.firestore().collection("tips")
    
    
    func getTipOfTheDay() async throws -> Tip? {
        return try await collection.order(by: "date", descending: true)
            .limit(to: 1)
            .getDocuments(as: Tip.self)
            .first
    }
    
}
