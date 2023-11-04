//
//  UserDao.swift
//  Vondera
//
//  Created by Shreif El Sayed on 01/06/2023.
//

import Foundation
import FirebaseFirestoreSwift
import FirebaseFirestore

class UsersDao {
    let collection = Firestore.firestore().collection("users")
    
    func getUserWithStore(userId:String) async throws -> UserData? {
        let result = try await collection.document(userId).getDocument(as: UserData.self)
        guard result.exists else {
            return nil
        }
        
        var user = result.item
        let store = try await StoresDao().getStore(uId: user.storeId)
        user.store = store
        return user
    }
    
    func storeEmployees(expect:String, storeId:String, active:Bool) async throws -> [UserData] {
        return try await collection
            .whereField("id", isNotEqualTo: expect)
            .whereField("storeId", isEqualTo: storeId)
            .whereField("active", isEqualTo: active)
            .getDocuments(as: UserData.self)
    }
    

    
    func phoneExist(phone:String) async throws -> Bool {
        let docs = try await collection.whereField("phone", isEqualTo: phone).getDocuments()
        return docs.count > 0
    }
    
    func emailExists(email:String) async throws -> Bool {
        let docs = try await collection.whereField("email", isEqualTo: email).getDocuments()
        return docs.count > 0
    }
    
    func googleIdExists(googleId:String) async throws -> Bool {
        let docs = try await collection.whereField("googleId", isEqualTo: googleId).getDocuments()
        return docs.count > 0
    }
    
    func facebookIdExists(facebookId:String) async throws -> Bool {
        let docs = try await collection.whereField("facebookId", isEqualTo: facebookId).getDocuments()
        return docs.count > 0
    }
    
    func appleIdExists(appleId:String) async throws -> Bool {
        let docs = try await collection.whereField("appleId", isEqualTo: appleId).getDocuments()
        return docs.count > 0
    }
    
    func getOnlineUser(expectId:String, storeId:String) async throws -> [UserData] {
        return try await collection
            .whereField("storeId", isEqualTo: storeId)
            .whereField("online", isEqualTo: true)
            .whereField("id", isNotEqualTo: expectId)
            .getDocuments(as: UserData.self)
    }
    
    func update(id:String, hash:[String:Any]) async throws {
        return try await collection.document(id).updateData(hash)
    }
    
    func addUser(user: UserData) async throws {
        return try collection.document(user.id).setData(from: user)
    }
    
    func getUser(uId:String) async throws -> (item: UserData?, exists:Bool) {
        return try await collection.document(uId).getDocument(as: UserData.self)
    }
    
    func convertToList(snapShot:QuerySnapshot) -> [UserData] {
        let arr = snapShot.documents.compactMap{doc -> UserData? in
            return try! doc.data(as: UserData.self)
        }
        
        return arr
    }
    
}
