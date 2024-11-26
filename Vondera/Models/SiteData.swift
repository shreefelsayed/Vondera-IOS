//
//  SiteData.swift
//  Vondera
//
//  Created by Shreif El Sayed on 28/10/2023.
//

import Foundation

struct SiteData: Codable {
    var requireEmail: Bool? = true
    var sendEmailToCustomer: Bool? = true
    var prePaidProducts: Bool? = true
    var whatsappButton: Bool? = true
    var lastPiece: Bool? = true
    var askForAddress: Bool? = true
    var reviewsEnabled: Bool? = true
    var canSingleCheckout:Bool? = false
    
    var themeId: Int? = 1
    var fontId: Int? = 1
    
    var minOrderAmount: Double? = 0.0
    var listCover: [String]? = []
    var listBanners: [String]? = []
    
    var primaryColor: String? = "#673ab7"
    var secondaryColor: String? = "#FAFAFA"
    
    var customerAccountsEnabled: Bool? = true
    var featuredText: String? = "Featured Products"
    var topSellingText: String? = "Top Selling"
    var websiteLanguage: [String]? = ["ar", "en"]
    
    // New variables added
    var productTextColor: String? = "#FFFFFF"
    var bgColor: String? = "#FFFFFF"
    var listBannerBgColor: String? = "#FFFFFF"
    var listBannerTextColor: String? = "#FFFFFF"
    var productImageBgColor: String? = "#FFFFFF"
    var buttonBgColor: String? = "#FFFFFF"
    var buttonTextColor: String? = "#FFFFFF"
    var floatingBgColor: String? = "#FFFFFF"
    var footerBgColor: String? = "#FFFFFF"
    var footerTextColor: String? = "#FFFFFF"
}


