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
        
        return convertToList(snapShot: try await collection
            .order(by: "count", descending: true)
            .whereField("count", isGreaterThan: 0)
            .limit(to: 10)
            .getDocuments())
        
    }
    
    
    func convertToList(snapShot:QuerySnapshot) -> [GovStatics] {
        let arr = snapShot.documents.compactMap{doc -> GovStatics? in
            return try! doc.data(as: GovStatics.self)
        }
        
        return arr
    }
}
