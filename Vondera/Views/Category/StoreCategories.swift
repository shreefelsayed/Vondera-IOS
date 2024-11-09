//
//  StoreCategories.swift
//  Vondera
//
//  Created by Shreif El Sayed on 25/06/2023.
//

import SwiftUI
import AlertToast

struct StoreCategories: View {
    var store:Store
    @StateObject private var viewModel:StoreCategoriesViewModel
    
    @State private var draggingIndex: Int?
    @State private var draggedItem : Category?
    @State private var editCategory: Category?
    @Environment(\.presentationMode) private var presentationMode

    init(store: Store) {
        self.store = store
        self._viewModel = StateObject(wrappedValue: StoreCategoriesViewModel(store: store))
    }
    
    var body: some View {
        List {
            ForEach($viewModel.items) { item in
                if item.wrappedValue.filter(searchText: viewModel.searchText) {
                    NavigationLink(destination: {
                        SubCategoriesScreen(category: item.wrappedValue, storeId: store.ownerId)
                    }, label: {
                        CategoryLinear(category: item)
                    })
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button {
                            self.editCategory = item.wrappedValue
                        } label: {
                            Image(systemName: "pencil")
                        }
                        .tint(.blue)
                    }
                }
            }
            .onMove { indexSet, index in
                viewModel.items.move(fromOffsets: indexSet, toOffset: index)
                Task {
                    await viewModel.updateIndexes()
                }
            }
        }
        .searchable(text: $viewModel.searchText, prompt: "Search \(viewModel.items.count) Categories")
        .refreshable {
            await viewModel.getData()
        }
        .listStyle(.plain)
        .navigationTitle("Categories")
        .toolbar{
            if UserInformation.shared.user?.accountType != "Marketing" {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: CreateCategory(storeId: store.ownerId, onAdded: { newValue in
                        onItemAdded(newValue)
                    })) {
                        Image(systemName: "plus.app")
                    }
                    .buttonStyle(.plain)
                    .bold()
                }
            }
        }
        .sheet(item: $editCategory, content: { cat in
            NavigationStack {
                EditCategory(category: cat, storeId: store.ownerId) { newValue in
                    onItemUpdated(newValue)
                } onDeleted: { deletedItem in
                    onDelete(deletedItem)
                }
            }
        })
        .willLoad(loading: viewModel.loading)
        .overlay {
            if !viewModel.loading && viewModel.items.count == 0 {
                EmptyMessageViewWithButton(systemName: "cart.fill.badge.plus", msg: "No categories were added to your store yet !") {
                    VStack {
                        NavigationLink(destination: CreateCategory(storeId: store.ownerId, onAdded: { newValue in
                            onItemAdded(newValue)
                        })) {
                            Text("Create new Category")
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
        }
        .withAccessLevel(accessKey: .categoriesRead, presentation: presentationMode)
    }
    
    func onItemAdded(_ item:Category) {
        withAnimation {
            viewModel.items.append(item)
            viewModel.msg = "New Category Added"
        }
    }
    
    func onItemUpdated(_ item:Category) {
        let index = viewModel.items.firstIndex { $0.id == item.id }
        if let index = index {
            DispatchQueue.main.async {
                withAnimation {
                    viewModel.items[index] = item
                    viewModel.msg = "Updated"
                }
            }
        }
        
        editCategory = nil
    }
    
    func onDelete(_ item:Category) {
        withAnimation {
            if let index = viewModel.items.firstIndex(where: { $0.id == item.id }) {
                viewModel.items.remove(at: index)
                viewModel.msg = "Category Deleted"
            }
        }
        
        editCategory = nil
    }
}

struct StoreCategories_Previews: PreviewProvider {
    static var previews: some View {
        StoreCategories(store: Store.example())
    }
}
