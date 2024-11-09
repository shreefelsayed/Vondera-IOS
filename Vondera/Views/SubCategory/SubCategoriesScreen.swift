//
//  SubCategoriesScreen.swift
//  Vondera
//
//  Created by Shreif El Sayed on 09/11/2024.
//

import SwiftUI

struct SubCategoriesScreen: View {
    var category:Category
    var storeId:String
    
    @State private var isLoading = false
    @State private var items:[SubCategory] = []
    
    @State private var draggingIndex: Int?
    @State private var draggedItem : SubCategory?
    @State private var editCategory: SubCategory?
    
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        List {
            ForEach($items, id: \.id) { item in
                SubCategoryLinear(category: item)
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        NavigationLink {
                            CreateSubCategory(storeId: storeId, category: category, subCategory: item.wrappedValue) { newCategory in
                                onItemUpdated(newCategory)
                            }
                        } label: {
                            Image(systemName: "pencil")
                        }
                        .tint(.blue)
                        
                        /*Button {
                            self.editCategory = item.wrappedValue
                        } label: {
                            
                        }*/
                        
                        
                        Button(role: .destructive) {
                            onDelete(item.wrappedValue)
                        } label: {
                            Image(systemName: "trash")
                        }
                        .tint(.red)
                    }
            }
            .onMove { indexSet, index in
                items.move(fromOffsets: indexSet, toOffset: index)
                Task {
                    await updateIndexes()
                }
            }
        }
        .refreshable {
            await fetch()
        }
        .listStyle(.plain)
        .navigationTitle(category.name)
        .toolbar{
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    CreateSubCategory(storeId: storeId, category: category, subCategory: nil) { newCategory in
                        onItemAdded(newCategory)
                    }
                } label: {
                    Image(systemName: "plus.app")
                }
                .buttonStyle(.plain)
                .bold()
            }
        }
        /*.sheet(item: $editCategory, content: { cat in
         NavigationStack {
         EditCategory(category: cat, storeId: store.ownerId) { newValue in
         onItemUpdated(newValue)
         } onDeleted: { deletedItem in
         onDelete(deletedItem)
         }
         }
         })*/
        .willLoad(loading: isLoading)
        .overlay {
            if !isLoading && items.count == 0 {
                EmptyMessageViewWithButton(systemName: "cart.fill.badge.plus", msg: "No Sub categories were added to this category !") {
                    VStack {
                        NavigationLink {
                            CreateSubCategory(storeId: storeId, category: category, subCategory: nil) { newCategory in
                                onItemAdded(newCategory)
                            }
                        } label: {
                            Text("Create a New Sub Category")
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
        }
        .task { await fetch() }
        .withAccessLevel(accessKey: .categoriesRead, presentation: presentationMode)
    }
    
    func fetch() async {
        DispatchQueue.main.async { self.isLoading = true }
        do {
            let result = try await SubStoreCategoryDao(storeId: storeId).getCategorySubItem(categoryId: category.id)
            DispatchQueue.main.async {
                self.items = result
                self.isLoading = false
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func updateIndexes() async {
        do {
            for (index, cat) in items.enumerated() {
                try await SubStoreCategoryDao(storeId: storeId).update(id: cat.id, data: ["sortValue":index])
                DispatchQueue.main.async {
                    self.items[index].sortValue = index
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func onItemAdded(_ item:SubCategory) {
        withAnimation {
            items.append(item)
        }
    }
    
    func onItemUpdated(_ item:SubCategory) {
        let index = items.firstIndex { $0.id == item.id }
        if let index = index {
            DispatchQueue.main.async {
                withAnimation {
                    items[index] = item
                }
            }
        }
        
        editCategory = nil
    }
    
    func onDelete(_ item:SubCategory) {
        withAnimation {
            if let index = items.firstIndex(where: { $0.id == item.id }) {
                items.remove(at: index)
            }
        }
        
        Task {
            try? await SubStoreCategoryDao(storeId: storeId).delete(id: item.id)
        }
        
        editCategory = nil
    }
}
