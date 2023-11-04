//
//  SiteData.swift
//  Vondera
//
//  Created by Shreif El Sayed on 28/10/2023.
//

import Foundation

struct SiteData : Codable {
    var requireEmail:Bool? = true
    var sendEmailToCustomer:Bool? = true
    var prePaidProducts:Bool? = true
    var whatsappButton:Bool? = true
    var themeId:Int? = 1
    var listCover:[String]? = [String]()
    var primaryColor:String? = "#673ab7"
    var secondaryColor:String? = "#FAFAFA"
}
