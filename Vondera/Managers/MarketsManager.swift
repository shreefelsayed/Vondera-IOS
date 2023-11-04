//
//  MarketsManager.swift
//  Vondera
//
//  Created by Shreif El Sayed on 28/09/2023.
//

import Foundation

class MarketsManager {
    
    func getList(selected: [String]) -> [StoreMarketPlace] {
        let all = getDefaultMarkets()
        var selectedItems = [StoreMarketPlace]()

        for storeMarkets in all {
            if selected.contains(storeMarkets.id) {
                selectedItems.append(StoreMarketPlace(id: storeMarkets.id, active: true))
            } else {
                selectedItems.append(StoreMarketPlace(id: storeMarkets.id, active: false))
            }
        }

        return selectedItems
    }

    func getDefaultMarkets() -> [StoreMarketPlace] {
        let storeCategories = getAllMarketPlaces()
        var markets:[StoreMarketPlace] = []

        for category in storeCategories {
            markets.append(StoreMarketPlace(id: category.id, active: false))
        }

        return markets
    }

    func getEnabledMarkets(storeMarkets: [StoreMarketPlace]) -> [Markets] {
        var list = [Markets]()

        for storeMarket in storeMarkets {
            if storeMarket.active {
                if let market = getById(id: storeMarket.id) {
                    list.append(market)
                }
            }
        }

        return list
    }

    func getById(id: String) -> Markets? {
        if id == "ecommerce" {
            return Markets(id: "ecommerce", name: "Website", icon: "icon", startColor: "FFFFFF", endColor: "#FFFFFF")
        }
        
        let list = getAllMarketPlaces()
        for market in list {
            if market.id == id {
                return market
            }
        }

        return nil
    }

    func getAllMarketPlaces() -> [Markets] {
        var list = [Markets]()
        let ids = [
            "instagram",
            "facebook",
            "amazon",
            "ebay",
            "shopify",
            "wordpress",
            "etsy",
            "woocommerce",
            "whatsapp",
            "tiktok",
            "telegram"
        ]
        
        let names = [
            "Instagram",
            "Facebook",
            "Amazon",
            "Ebay",
            "Shopify",
            "Wordpress",
            "Etsy",
            "Woocommerce",
            "Whatsapp",
            "Tiktok",
            "Telegram"
        ]
        
        let images = [
            "instagram-bw",
            "facebook-bw",
            "amazon",
            "ebay",
            "shopify-bw",
            "wordpress",
            "etsy",
            "woo",
            "whatsapp",
            "tiktok",
            "telegram"
        ]

        for (i, id) in ids.enumerated() {
            let gradientColors = getGradientColors(id: id)
            list.append(Markets(id: id, name: names[i], icon: images[i], startColor: gradientColors[0], endColor: gradientColors[1]))
        }

        return list
    }

    func getGradientColors(id: String) -> [String] {
        switch id {
        case "instagram":
            return ["#E4405F", "#ECB22E"]
        case "facebook":
            return ["#1877F2", "#42B72A"]
        case "amazon":
            return ["#FF9900", "#FFCC00"]
        case "ebay":
            return ["#E53238", "#F5AF02"]
        case "shopify":
            return ["#7AB55C", "#00AEEF"]
        case "wordpress":
            return ["#21759B", "#D54E21"]
        case "etsy":
            return ["#F25876", "#FFACCC"]
        case "woocommerce":
            return ["#96588A", "#D6A3C1"]
        case "whatsapp":
            return ["#075E54", "#128C7E"]
        case "tiktok":
            return ["#69C9D0", "#EE1D52"]
        case "telegram":
            return ["#8E44AD", "#3498DB"]
        default:
            return ["#FFFFFF", "#FFFFFF"]
        }
    }

}
