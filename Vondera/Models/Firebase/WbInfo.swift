//
//  WbInfo.swift
//  Vondera
//
//  Created by Shreif El Sayed on 03/07/2024.
//

import Foundation

struct WbInfo: Codable {
    var instanceId:String = ""
    var apiToken:String = ""
    var useVondera:Bool = true
    var newOrder:WBMessage = WBMessage()
    var shipping:WBMessage = WBMessage()
    var delivered:WBMessage = WBMessage()
}

struct WBMessage: Codable {
    var active = false
    var msg:String = ""
}
