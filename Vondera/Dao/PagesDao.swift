//
//  PagesDao.swift
//  Vondera
//
//  Created by Shreif El Sayed on 28/10/2023.
//

import Foundation
import FirebaseFirestore

class PagesDao {
    var collection:CollectionReference
    
    init(storeId:String) {
        self.collection = Firestore.firestore().collection("stores").document(storeId).collection("pages")
    }
    
    func doesExist(id:String) async -> Bool {
        do {
            let doc = try await collection.document(id).getDocument()
            return doc.exists
        } catch {
            return true
        }
    }
    
    func getSortValue() async -> Int {
        do {
            let doc = try await collection.count.getAggregation(source: .server)
            return doc.count.intValue
        } catch {
            return 0
        }
    }
    
    func delete(_ id:String) async throws {
        return try await collection.document(id).delete()
    }
    
    func update(_ id:String, map:[String:Any]) async throws {
        return try await collection.document(id).updateData(map)
    }
    
    func addPage(_ page:WebsiteSection) async throws {
        return try collection.document(page.id).setData(from: page)
    }
    
    func getPages() async throws -> [WebsiteSection] {
        return try await collection
            .order(by: "sortValue", descending: true)
            .getDocuments(as: WebsiteSection.self)
    }
}
