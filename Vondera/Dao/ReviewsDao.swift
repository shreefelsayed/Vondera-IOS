//
//  ReviewsDao.swift
//  Vondera
//
//  Created by Shreif El Sayed on 28/03/2024.
//

import Foundation
import FirebaseFirestore

class ReviewsDao {
    var collection:CollectionReference
    let pageSize = 20
    
    init(storeId:String, productId:String) {
        self.collection = Firestore.firestore().collection("stores").document(storeId).collection("products").document(productId)
            .collection("reviews")
    }
    
    func removeReview(id:String) async throws {
        return try await collection.document(id).delete()
    }
    func getReviews(lastSnapshot:DocumentSnapshot?) async throws -> (items: [ReviewModel], lastDocument: DocumentSnapshot?) {
        return try await collection
            .order(by: "date", descending: true)
            .limit(to: pageSize)
            .startAfter(lastDocument: lastSnapshot)
            .getDocumentWithLastSnapshot(as: ReviewModel.self)
    }
}
