//
//  FirebaseExt.swift
//  Vondera
//
//  Created by Shreif El Sayed on 16/10/2023.
//

import Foundation
import FirebaseFirestore
import FirebaseCrashlytics

extension DocumentReference {
    func getDocument<T>(as type: T.Type) async throws -> (item : T, exists : Bool) where T : Decodable {
        let doc = try await self.getDocument()
        let item = try doc.data(as: type)
        
        return (item, doc.exists)
    }
}

extension Query {
    
    func startAfter(lastDocument:DocumentSnapshot?) -> Query {
        if let snapshot = lastDocument {
            return self.start(afterDocument: snapshot)
        }
        
        return self
    }
    
    func getCount() async throws -> Int {
        return try await self.count.getAggregation(source: .server).count.intValue
    }
    
    func getDocuments<T>(as type: T.Type) async throws -> [T] where T : Decodable {
        try await getDocumentWithLastSnapshot(as: type).items
    }
    
    func getDocumentWithLastSnapshot<T>(as type: T.Type) async throws -> (items: [T], lastDocument: DocumentSnapshot?) where T : Decodable {
        
        var items = [T]()
        let snapshot = try await self.getDocuments()
        
        for document in snapshot.documents {
            do {
                items.append(try document.data(as: T.self))
            } catch {
                Crashlytics.crashlytics().record(error: error, userInfo: ["errorInfo" : "Error at \(document.reference.path) with \(error)"])
                print("Error at \(document.reference.path) with \(error)")
            }
        }

        
        return(items,snapshot.documents.last)
    }
}
