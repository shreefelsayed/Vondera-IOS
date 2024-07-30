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
    
    func getStore(uId:String) async throws -> Store? {
        let store = try await collection.document(uId).getDocument(as: Store.self).item
        guard var store = store else { return nil }
        
        if store.siteData == nil {
            store.siteData = SiteData()
        }
        
        return store
    }
    
    func getStores(lastSnapshot:DocumentSnapshot?, sorting:String = "date") async throws -> ([Store], DocumentSnapshot?) {
        return try await collection
            .order(by: sorting, descending: true)
            .startAfter(lastDocument: lastSnapshot)
            .limit(to: 25)
            .getDocumentWithLastSnapshot(as: Store.self)
    }
    
    func getWithHiddenOrders(lastSnapshot:DocumentSnapshot?) async throws -> ([Store], DocumentSnapshot?) {
        return try await collection
            .order(by: "hiddenOrders", descending: true)
            .whereField("hiddenOrders", isGreaterThan: 0)
            .startAfter(lastDocument: lastSnapshot)
            .limit(to: 25)
            .getDocumentWithLastSnapshot(as: Store.self)
    }
    
    func getCurrentlySubscribed(lastSnapshot:DocumentSnapshot?) async throws -> ([Store], DocumentSnapshot?) {
        return try await collection
            .whereField("renewCount", isGreaterThan: 0)
            .whereField("storePlanInfo.planId", isNotEqualTo: "free")
            .startAfter(lastDocument: lastSnapshot)
            .limit(to: 25)
            .getDocumentWithLastSnapshot(as: Store.self)
    }
    
    func getStopedSubscribing(lastSnapshot:DocumentSnapshot?) async throws -> ([Store], DocumentSnapshot?) {
        return try await collection
            .whereField("renewCount", isGreaterThan: 0)
            .whereField("storePlanInfo.planId", isEqualTo: "free")
            .startAfter(lastDocument: lastSnapshot)
            .limit(to: 25)
            .getDocumentWithLastSnapshot(as: Store.self)
    }
    
    func getStoresWithWallets() async throws -> [Store] {
        return try await collection
            .order(by: "vPayWallet", descending: true)
            .whereField("vPayWallet", isGreaterThan: 15)
            .getDocuments(as: Store.self)
    }
    
    func search(query:String) async throws -> [Store] {
        return try await collection
            .order(by: "merchantId", descending: false)
            .whereField("merchantId", isEqualTo: query)
            .getDocuments(as: Store.self)
    }
    
    func update(id:String, hashMap:[String:Any]) async throws {
        return try await collection.document(id).updateData(hashMap)
    }
}

