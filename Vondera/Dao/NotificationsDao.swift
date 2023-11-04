//
//  NotificationsDao.swift
//  Vondera
//
//  Created by Shreif El Sayed on 23/10/2023.
//

import Foundation
import FirebaseFirestore

class NotificationsDao {
    var collectionRefrence:CollectionReference
    
    init(userId:String) {
        self.collectionRefrence = Firestore.firestore().collection("users").document(userId).collection("notifications")
    }
    
    func markAsRead(id:String) async throws {
        return try await collectionRefrence.document(id).updateData(["read":true])
    }
    func notificationListener() -> Query {
        return collectionRefrence.whereField("read", isEqualTo: false)
    }
    
    func removeNotification(id:String) async {
        try? await collectionRefrence.document(id).delete()
    }
    
    func getNotifications(lastSnapshot:DocumentSnapshot?) async throws -> (items: [NotificationModel], lastDocument: DocumentSnapshot?) {
        
        return try await collectionRefrence
            .order(by: "date", descending: true)
            .limit(to: 30)
            .startAfter(lastDocument: lastSnapshot)
            .getDocumentWithLastSnapshot(as: NotificationModel.self)
    }
    
    func getNewNotificationsCount() async throws -> Int {
        let object = try await collectionRefrence.whereField("read", arrayContains: false)
            .count
            .getAggregation(source: .server)
        
        return object.count.intValue
    }
}
