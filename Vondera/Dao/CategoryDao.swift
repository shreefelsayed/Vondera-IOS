//
//  CategoryDao.swift
//  Vondera
//
//  Created by Shreif El Sayed on 22/06/2023.
//

import Foundation
import FirebaseFirestoreSwift
import FirebaseFirestore

class CategoryDao {
    var collection:CollectionReference
    
    init(storeId:String) {
        self.collection = Firestore.firestore().collection("stores").document(storeId).collection("category")
    }
    
    func update(id:String, hash:[String:Any]) async throws {
        return try await collection.document(id).updateData(hash)
        
    }
    
    func delete(id:String) async throws {
        return try await collection.document(id).delete()
        
    }
    
    func add(category: inout Category) async throws {
        category.id = collection.document().documentID
        try await collection.document(category.id).setData(category.asDicitionry())
        print("Added to database")
    }
    
    func get(id:String) async throws -> Category {
        return try await collection.document(id).getDocument(as: Category.self)
    }
    
    func getAll() async throws -> [Category] {
        print("Data ref \(collection.path)")
        let docs = try await collection
            .order(by: "sortValue", descending: false)
            .getDocuments()
        
        print("Docs found \(docs.count)")
        return convertToList(snapShot: docs)
        
    }
    
    func convertToList(snapShot:QuerySnapshot) -> [Category] {
        let arr = snapShot.documents.compactMap{doc -> Category? in
            return try! doc.data(as: Category.self)
        }
        
        return arr
    }
}
