//
//  CategoryPicker.swift
//  Vondera
//
//  Created by Shreif El Sayed on 23/06/2023.
//

import SwiftUI

struct CategoryPicker: View {
    let items: [Category]
    @Binding var selectedItem: Category?
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView (showsIndicators: false) {
                VStack {
                    ForEach(items) { category in
                        CategoryLinear(category: category, isSelected: category.id == selectedItem?.id ?? "") {
                            selectedItem = category
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            }
            .padding()
            .navigationTitle("Categories")
            
        }
    }
}
