//
//  GovStatics.swift
//  Vondera
//
//  Created by Shreif El Sayed on 20/06/2023.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct GovStatics: Codable, Hashable {
    @DocumentID var name:String?
    var count:Int = 0
}

extension GovStatics {
    static func listExample() -> [GovStatics] {
        var list = [GovStatics]()
        for _ in 1...10 {
            list.append(example())
        }
        
        return list
    }
    static func example() -> GovStatics {
        return GovStatics(name: "Cairo", count: 20)
    }
}
