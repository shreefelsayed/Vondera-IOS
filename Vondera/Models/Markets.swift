//
//  Markets.swift
//  Vondera
//
//  Created by Shreif El Sayed on 28/09/2023.
//

import Foundation

struct Markets : Codable, Identifiable {
    var id: String = "" //instagram , facebook, amazon, ebay, shopify, wordpress, etsy, woocommerce, website
    var name:String = ""
    var icon:String = ""
    var startColor = ""
    var endColor = ""
}

extension Markets {
    static func example() -> Markets {
        return MarketsManager().getAllMarketPlaces()[0]
    }
}
