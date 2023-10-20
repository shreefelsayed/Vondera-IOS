//
//  StoreCategory.swift
//  Vondera
//
//  Created by Shreif El Sayed on 27/09/2023.
//

import Foundation
struct StoreCategory: Codable, Equatable, Hashable {
    var id:Int = 0
    var drawableId = "category"
    var nameEn = ""
    var nameAr = ""
    
    init(id: Int, drawableId: String = "category", nameEn: String = "", nameAr: String = "") {
        self.id = id
        self.drawableId = drawableId
        self.nameEn = nameEn
        self.nameAr = nameAr
    }
    
    
}

extension StoreCategory {
    static func example() -> StoreCategory {
        return StoreCategory(id: 0, drawableId: "category1", nameEn: "Fashion", nameAr: "الموضه")
    }
}
