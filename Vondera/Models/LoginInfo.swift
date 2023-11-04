//
//  LoginInfo.swift
//  Vondera
//
//  Created by Shreif El Sayed on 17/10/2023.
//

import Foundation
import Firebase

struct AuthProviderInfo : Identifiable, Hashable  {
    var id:String
    var name: String
    var url:String
    var email:String
    var provider:String // "google", "apple", "facebook"
    var cred:AuthCredential
}

struct LoginInfo : Identifiable, Hashable, Codable {
    var id = ""
    var name = ""
    var email = ""
    var password = ""
    var url = "" // Image url of the user
    var accountType = ""
    var storeName = ""
}
