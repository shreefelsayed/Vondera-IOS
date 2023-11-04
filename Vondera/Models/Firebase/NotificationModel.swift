//
//  NotificationModel.swift
//  Vondera
//
//  Created by Shreif El Sayed on 23/10/2023.
//

import Foundation
import FirebaseFirestore

struct NotificationModel: Codable, Identifiable, Equatable {
    var id = ""
    var read = false
    var title = ""
    var body = ""
    var date:Timestamp = Timestamp(date: Date())
    var type = ""
    var objectId = ""
    
    init(id: String = "", read: Bool = false, title: String = "", body: String = "", date: Timestamp, type: String = "", objectId: String = "") {
        self.id = id
        self.read = read
        self.title = title
        self.body = body
        self.date = date
        self.type = type
        self.objectId = objectId
    }
    
    init() {
        
    }
    
    static func ==(lhs: NotificationModel, rhs: NotificationModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    
}
