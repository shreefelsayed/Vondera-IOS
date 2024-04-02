//
//  ReviewModel.swift
//  Vondera
//
//  Created by Shreif El Sayed on 28/03/2024.
//

import Foundation
import FirebaseFirestore

struct ReviewModel: Identifiable, Codable {
    var id:String
    var rating:Double
    var name:String
    var email:String
    var review:String
    var date:Timestamp
}

extension ReviewModel {
    static func example() -> ReviewModel {
        return ReviewModel(id: UUID().uuidString, rating: 4.5, name: "Shreef El Sayed", email: "armjldtrainer@gmail.com", review: "This is a dumb review data", date: Date().toFirestoreTimestamp())
    }
}
