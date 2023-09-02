//
//  StoresDao.swift
//  Vondera
//
//  Created by Shreif El Sayed on 01/06/2023.
//

import Foundation
import FirebaseFirestoreSwift
import FirebaseFirestore

class StoresDao {
    let collection = Firestore.firestore().collection("stores")
    
    func addStore(store: Store) async throws {
        return try! collection.document(store.ownerId).setData(from: store)
    }
    
    func deleteStore(id:String) async throws {
        return try await collection.document(id).delete()
    }
    
    func getStore(uId:String) async throws -> Store? {
        let doc = try await collection.document(uId).getDocument()
        if !doc.exists {return nil}
        return try doc.data(as: Store.self)
    }
    
    func update(id:String, hashMap:[String:Any]) async throws {
        return try await collection.document(id).updateData(hashMap)
    }
    
}

