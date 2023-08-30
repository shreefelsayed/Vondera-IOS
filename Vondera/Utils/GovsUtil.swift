//
//  GovsUtil.swift
//  Vondera
//
//  Created by Shreif El Sayed on 28/06/2023.
//

import Foundation

class GovsUtil {
    var govs = ["القاهرة", "القاهره - مدن جديده", "الجيزة", "الإسكندرية", "القليوبية", "الإسماعيلية", "أسيوط", "البحر الأحمر", "البحيرة", "بني سويف", "بورسعيد", "جنوب سيناء", "بورسعيد", "الدقهلية", "دمياط", "سوهاج", "السويس", "الشرقية", "شمال سيناء", "الغربية", "الفيوم", "الغربية", "قنا", "كفر الشيخ", "مطروح", "المنوفية", "المنيا", "أسوان", "الأقصر", "الوادي الجديد"]
    
    var defaultForStores = ["القاهرة", "الجيزة", "القاهره - المدن الجديده", "الإسكندرية"]
    
    func getStoreDefault() -> [CourierPrice] {
        return defaultForStores.map { CourierPrice(govName: $0, price: 0)}
    }
    
    func getDefaultCourierList() -> [CourierPrice] {
        return govs.map { CourierPrice(govName: $0, price: 0)}
    }
}
