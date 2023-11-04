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
    
    func validId(id:String) async throws -> Bool {
        if !id.containsOnlyEnglishLetters() {return false}
        if id.count < 3 {
            return false
        }
        
        let docs = try await collection.whereField("merchantId", isEqualTo: id.lowercased().replacingOccurrences(of: " ", with: "")).getDocuments()
        return docs.count == 0
    }
    
    func deleteStore(id:String) async throws {
        return try await collection.document(id).delete()
    }
    
    func getStore(uId:String) async throws -> Store {
        let store = try await collection.document(uId).getDocument(as: Store.self).item
        
        if store.siteData == nil {
            store.siteData = SiteData()
        }
        
        return store
    }
    
    func update(id:String, hashMap:[String:Any]) async throws {
        return try await collection.document(id).updateData(hashMap)
    }
}

