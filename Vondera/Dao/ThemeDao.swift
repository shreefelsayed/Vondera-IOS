//
//  ThemeDao.swift
//  Vondera
//
//  Created by Shreif El Sayed on 09/11/2024.
//

import FirebaseFirestore
import Foundation

class ThemeDao {
    let collectionRefrence = Firestore.firestore().collection("siteThemes")
    
    func getThemes() async throws -> [ThemeModel] {
        return try await collectionRefrence
            .order(by: "id", descending: false)
            .getDocuments(as: ThemeModel.self)
    }
}

struct ThemeModel: Codable {
    var id: Int = 0
    var minLevel: Int = 0
    var name: String = ""
    var previewLink: String = ""
}
