//
//  CouriersDao.swift
//  Vondera
//
//  Created by Shreif El Sayed on 22/06/2023.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class CouriersDao {
    var collection:CollectionReference
    
    init(storeId:String) {
        self.collection = Firestore.firestore().collection("stores").document(storeId).collection("courier")
    }
    
    func addCourier(courier: inout Courier) async throws {
        if courier.id.isEmpty {
            courier.id  = collection.document().documentID
        }        
        return try collection.document(courier.id ).setData(from: courier)
    }
    
    func getCourier(id:String) async throws -> Courier {
        return try await collection.document(id).getDocument(as: Courier.self)
        
    }
    
    func getByVisibility(isVisible:Bool = true) async throws -> [Courier] {
        return convertToList(snapShot: try await collection
            .whereField("visible", isEqualTo: isVisible)
            .getDocuments())
        
    }
    
    func getStoreCouriers() async throws -> [Courier] {
        return convertToList(snapShot: try await collection.getDocuments())
        
    }
    
    func getByStatue(statue:Bool = true) async throws -> [Courier] {
        return convertToList(snapShot: try await collection
            .whereField("visible", isEqualTo: statue)
            .getDocuments())
        
    }
    
    func update(id:String, hashMap:[String:Any]) async throws {
        return try await collection.document(id).updateData(hashMap)
    }
    
    func convertToList(snapShot:QuerySnapshot) -> [Courier] {
        let arr = snapShot.documents.compactMap{doc -> Courier? in
            return try! doc.data(as: Courier.self)
        }
        
        return arr
    }
}
