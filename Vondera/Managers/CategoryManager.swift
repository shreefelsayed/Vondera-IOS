//
//  CategoryManager.swift
//  Vondera
//
//  Created by Shreif El Sayed on 27/09/2023.
//

import Foundation

class CategoryManager {
    
    func getCategoryById(id:Int) -> StoreCategory {
        return getAll()[id]
    }
    
    func getAll() -> [StoreCategory] {
        var items:[StoreCategory] = []
        
        items.append(StoreCategory(id: 0, drawableId: "category1", nameEn: "Apparel and Fashion", nameAr: "الأزياء والألبسة"))
        items.append(StoreCategory(id: 1, drawableId: "category2", nameEn: "Electronics and Gadgets", nameAr: "الإلكترونيات والأجهزة"))
        items.append(StoreCategory(id: 2, drawableId: "category3", nameEn: "Beauty and Cosmetics", nameAr: "الجمال ومستحضرات التجميل"))
        items.append(StoreCategory(id: 3, drawableId: "category4", nameEn: "Home and Furniture", nameAr: "المنزل والأثاث"))
        items.append(StoreCategory(id: 4, drawableId: "category5", nameEn: "Books and Media", nameAr: "الكتب والوسائط"))
        items.append(StoreCategory(id: 5, drawableId: "category6", nameEn: "Sports and Outdoors", nameAr: "الرياضة والهوايات الخارجية"))
        items.append(StoreCategory(id: 6, drawableId: "category7", nameEn: "Toys and Games", nameAr: "الألعاب والألعاب اللوحية"))
        items.append(StoreCategory(id: 7, drawableId: "category8", nameEn: "Health and Wellness", nameAr: "الصحة والعافية"))
        items.append(StoreCategory(id: 8, drawableId: "category9", nameEn: "Jewelry and Accessories", nameAr: "المجوهرات والإكسسوارات"))
        items.append(StoreCategory(id: 9, drawableId: "category10", nameEn: "Food and Beverages", nameAr: "الطعام والمشروبات"))
        items.append(StoreCategory(id: 10, drawableId: "category11", nameEn: "Automotive and Parts", nameAr: "السيارات وقطع الغيار"))
        items.append(StoreCategory(id: 11, drawableId: "category12", nameEn: "Pet Supplies", nameAr: "لوازم الحيوانات الأليفة"))
        items.append(StoreCategory(id: 12, drawableId: "category13", nameEn: "Art and Craft Supplies", nameAr: "لوازم الفنون والحرف اليدوية"))
        items.append(StoreCategory(id: 13, drawableId: "category14", nameEn: "Home Improvement", nameAr: "تحسين المنزل"))
        items.append(StoreCategory(id: 14, drawableId: "category15", nameEn: "Gifts and Novelties", nameAr: "الهدايا والتحف"))
        items.append(StoreCategory(id: 15, drawableId: "category16", nameEn: "Office Supplies", nameAr: "لوازم المكتب"))
        items.append(StoreCategory(id: 16, drawableId: "category17", nameEn: "Tech Gadgets", nameAr: "أجهزة التقنية"))
        items.append(StoreCategory(id: 17, drawableId: "category18", nameEn: "Specialty Stores", nameAr: "المتاجر المتخصصة"))
        items.append(StoreCategory(id: 18, drawableId: "category19", nameEn: "Subscription Boxes", nameAr: "صناديق الاشتراك"))
        items.append(StoreCategory(id: 19, drawableId: "category20", nameEn: "Service-Based E-commerce", nameAr: "خدمات"))
        items.append(StoreCategory(id: 20, drawableId: "category21", nameEn: "Others", nameAr: "أخري"))
        return items
    }
}
