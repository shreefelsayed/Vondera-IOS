//
//  Tip.swift
//  Vondera
//
//  Created by Shreif El Sayed on 20/06/2023.
//

import Foundation
import FirebaseFirestore

struct Tip: Codable {
    var ar:String = ""
    var en:String = ""
    var date:Timestamp = Timestamp(date: Date())
}

extension Tip {
    static func example() -> Tip {
        return Tip(ar: "يجب ان تقوم بمتابعتنا لمعرفه الكثير من التفاصيل عن التطبيق", en: "You have to follow us to know more about the app")
    }
}
