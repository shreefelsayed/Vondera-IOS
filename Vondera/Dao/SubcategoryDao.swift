//
//  SubcategoryDao.swift
//  Vondera
//
//  Created by Shreif El Sayed on 09/11/2024.
//

import Foundation
import FirebaseFirestore

class SubStoreCategoryDao {
    private var collectionReference: CollectionReference
    
    init(storeId: String) {
        collectionReference = Firestore.firestore().collection("stores").document(storeId).collection("subCategories")
    }
    
    func getCategorySubItem(categoryId: String) async throws -> [SubCategory] {
        return try await collectionReference
            .whereField("categoryId", isEqualTo: categoryId)
            .order(by: "sortValue", descending: false)
            .getDocuments(as: SubCategory.self)
    }
    
    func getAll() async throws -> [SubCategory] {
        return try await collectionReference
            .order(by: "sortValue", descending: false)
            .getDocuments(as: SubCategory.self)
    }
    
    func update(id: String, data: [String: Any]) async throws {
        try await collectionReference.document(id).updateData(data)
    }
    
    func getCategory(subCategoryId: String) async throws -> SubCategory {
        return try await collectionReference.document(subCategoryId).getDocument(as: SubCategory.self)
    }
    
    func addCategory(subCategory: SubCategory) async throws -> SubCategory{
        var newSubCategory = subCategory
        let lastIndex = try await getCategorySubItem(categoryId: subCategory.categoryId).count - 1
        newSubCategory.sortValue = lastIndex
        if newSubCategory.id.isEmpty {
            newSubCategory.id = collectionReference.document().documentID
        }
        
        try await collectionReference.document(newSubCategory.id).setData(newSubCategory.asDicitionry())
        return newSubCategory
    }
    
    func delete(id: String) async throws {
        try await collectionReference.document(id).delete()
    }
}
