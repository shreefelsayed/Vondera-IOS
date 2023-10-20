//
//  StoreCategory.swift
//  Vondera
//
//  Created by Shreif El Sayed on 29/09/2023.
//

import SwiftUI

struct StoreCategoryUpdate: View {
    @Binding var store:Store
    
    var body: some View {
        VStack {
            List(CategoryManager().getAll(), id: \.self) { category in
                StoreCategoryLinearCard(storeCategory: category, selected: bindingItem(category))
                .listRowInsets(EdgeInsets())
            }
        }
        .navigationTitle("Store Category")
    }
    
    func bindingItem(_ category: StoreCategory) -> Binding<Int?> {
        Binding<Int?>(
            get: {
            store.categoryNo ?? 21
        },
        set: { newValue in
            store.categoryNo = category.id
            
            // MARK : Update Firebase
            Task {
                try! await StoresDao().update(id: store.ownerId, hashMap: ["categoryNo" : newValue ?? 0])
            }
            
        })
    }
}

