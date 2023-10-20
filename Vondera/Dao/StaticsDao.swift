//
//  StoresDao.swift
//  Vondera
//
//  Created by Shreif El Sayed on 01/06/2023.
//

import Foundation
import FirebaseFirestoreSwift
import FirebaseFirestore

class StaticsDao {
    var collection:CollectionReference
    
    init(storeId:String) {
        self.collection = Firestore.firestore().collection("stores").document(storeId).collection("statics")
    }
    
    func getLastDays(days:Int) async throws -> [StoreStatics] {
        return convertToList(snapShot: try await collection.order(by: "date", descending: true)
            .limit(to: days)
            .getDocuments())
    }
    
    func convertToList(snapShot:QuerySnapshot) -> [StoreStatics] {
        let arr = snapShot.documents.compactMap{doc -> StoreStatics? in
            return try! doc.data(as: StoreStatics.self)
        }
        
        return arr
    }
}

