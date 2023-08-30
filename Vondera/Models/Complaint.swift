//
//  Complaint.swift
//  Vondera
//
//  Created by Shreif El Sayed on 25/06/2023.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Complaint: Codable, Identifiable {
    var id: String = ""
    var desc: String = ""
    var by: String = ""
    @ServerTimestamp var date: Timestamp? = Timestamp(date: Date())
    var state: String = "opened" // opened - closed
    var closedBy: String = ""
    var listPhotos: [String] = []
    var storeId: String = ""
    
    var byName: String = ""  // AUTO GENERATED
    var closedName: String = ""  // AUTO GENERATED
}
