//
//  CodesDao.swift
//  Vondera
//
//  Created by Shreif El Sayed on 28/10/2023.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift



class CodesDao {
    var collection:CollectionReference
    
    init(storeId:String) {
        self.collection = Firestore.firestore().collection("stores").document(storeId).collection("codes")
    }
    
    func doesExist(id:String) async -> Bool {
        do {
            let doc = try await collection.document(id).getDocument()
            return doc.exists
        } catch {
            return true
        }
    }
    
    func delete(_ id:String) async throws {
        return try await collection.document(id).delete()
    }
    
    func update(_ id:String, map:[String:Any]) async throws {
        return try await collection.document(id).updateData(map)
    }
    
    func addCode(_ discountCode:DiscountCode) async throws {
        return try collection.document(discountCode.id).setData(from: discountCode)
    }
    
    func getActive() async throws -> [DiscountCode] {
        return try await collection
            .whereField("active", isEqualTo: true)
            .order(by: "date", descending: true)
            .getDocuments(as: DiscountCode.self)
    }
    
}
