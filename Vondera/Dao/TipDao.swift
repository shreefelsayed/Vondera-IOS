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
        return convertToTipList(snapShot: try await collection.order(by: "date", descending: true)
            .limit(to: 1)
            .getDocuments())[0]
    }
    
    func convertToTipList(snapShot:QuerySnapshot) -> [Tip] {
        let arr = snapShot.documents.compactMap{doc -> Tip? in
            return try! doc.data(as: Tip.self)
        }
        
        return arr
    }
}
