//
//  Paytabs.swift
//  Vondera
//
//  Created by Shreif El Sayed on 31/10/2023.
//

import Foundation

class Paymob : Codable {
    var iframe:String? = ""
    var integrationId:String? = ""
    var apiKey:String? = ""
    var selected:Bool? = false
    var connected:Bool? = false
    var gateway:Bool? = true
}
