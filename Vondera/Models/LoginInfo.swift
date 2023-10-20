//
//  LoginInfo.swift
//  Vondera
//
//  Created by Shreif El Sayed on 17/10/2023.
//

import Foundation

struct LoginInfo : Identifiable, Hashable, Codable {
    var id = ""
    var name = ""
    var email = ""
    var password = ""
    var url = "" // Image url of the user
    var accountType = ""
    var storeName = ""
}
