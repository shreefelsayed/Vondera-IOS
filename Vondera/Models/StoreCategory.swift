//
//  StoreCategory.swift
//  Vondera
//
//  Created by Shreif El Sayed on 27/09/2023.
//

import Foundation
import SwiftUI

struct StoreCategory {
    var id:Int = 0
    var drawableId = "category"
    var name:LocalizedStringKey = ""
    
    init(id: Int, drawableId: String = "category", name: LocalizedStringKey = "") {
        self.id = id
        self.drawableId = drawableId
        self.name = name
    }
    
    
}

extension StoreCategory {
    static func example() -> StoreCategory {
        return CategoryManager().getAll()[0]
    }
}
