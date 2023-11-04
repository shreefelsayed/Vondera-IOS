//
//  GovsUtil.swift
//  Vondera
//
//  Created by Shreif El Sayed on 28/06/2023.
//

import Foundation

class GovsUtil {
    var govs = [
        "القاهرة",
        "القاهره - مدن جديده",
        "الجيزة",
        "الإسكندرية",
        "القليوبية",
        "الإسماعيلية",
        "أسيوط",
        "البحر الأحمر",
        "البحيرة",
        "بني سويف",
        "بورسعيد",
        "جنوب سيناء",
        "الدقهلية",
        "دمياط",
        "سوهاج",
        "السويس",
        "الشرقية",
        "شمال سيناء",
        "الغربية",
        "الفيوم",
        "قنا",
        "كفر الشيخ",
        "مطروح",
        "المنوفية",
        "المنيا",
        "أسوان",
        "الأقصر",
        "الوادي الجديد"
    ];
    
    func getStoreDefault() -> [CourierPrice] {
        return Array(govs.prefix(4)).map { CourierPrice(govName: $0, price: 0)}
    }
    
    func getDefaultCourierList() -> [CourierPrice] {
        return govs.map { CourierPrice(govName: $0, price: 0)}
    }
}
