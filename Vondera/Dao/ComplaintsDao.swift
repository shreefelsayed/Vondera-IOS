//
//  ComplaintsDao.swift
//  Vondera
//
//  Created by Shreif El Sayed on 25/06/2023.
//

import Foundation
import FirebaseFirestore

class ComplaintsDao {
    var collection:CollectionReference
    let pageSize = 20
    
    init(storeId:String) {
        self.collection = Firestore.firestore().collection("stores").document(storeId).collection("complaints")
    }
    
    func add(complaint: inout Complaint) async throws {
        if complaint.id.isBlank {
            complaint.id = collection.document().documentID
        }
    
        return try collection.document(complaint.id).setData(from: complaint)
    }
    
    func getComplaintByStatue(statue:String = "opened", lastSnapShot:DocumentSnapshot?) async throws -> ([Complaint], DocumentSnapshot?){
        return try await collection
            .whereField("state", isEqualTo: statue)
            .order(by: "date", descending: true)
            .startAfter(lastDocument: lastSnapShot)
            .limit(to: pageSize)
            .getDocumentWithLastSnapshot(as: Complaint.self)
    }
    
    func update(id:String, hashMap:[String:Any]) async throws {
        return try await collection.document(id).updateData(hashMap)
    }
    
    func getId() -> String {
        return collection.document().documentID
    }
}
