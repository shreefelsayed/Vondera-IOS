//
//  CategoryPicker.swift
//  Vondera
//
//  Created by Shreif El Sayed on 23/06/2023.
//

import SwiftUI

struct CategoryPicker: View {
    @Binding var items: [Category]
    let storeId:String
    @Binding var selectedItem: Category?
    @Environment(\.presentationMode) var presentationMode
    @State private var showAdd = false
    var body: some View {
        List {
            ForEach($items.indices, id: \.self) { index in
                CategoryLinear(category: $items[index], isSelected: items[index].id == selectedItem?.id ?? "")
                    .onTapGesture {
                        selectedItem = items[index]
                        presentationMode.wrappedValue.dismiss()
                    }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("New") {
                    showAdd.toggle()
                }
            }
        }
        .sheet(isPresented: $showAdd, content: {
            NavigationStack {
                CreateCategory(storeId: storeId) { newValue in
                    items.append(newValue)
                }
            }
            
        })
        .listStyle(.plain)
        .navigationTitle("Categories")
        
        
    }
}
