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
    @ObservedObject var viewModel:StoreCategoriesViewModel
    @State private var draggingIndex: Int?
    @State var draggedItem : Category?
    @State var editCategory: Category?
    
    init(store: Store) {
        self.store = store
        self.viewModel = StoreCategoriesViewModel(store: store)
    }
    
    var body: some View {
        List {
            ForEach($viewModel.items) { item in
                CategoryLinear(category: item)
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button {
                        self.editCategory = item.wrappedValue
                    } label: {
                        Image(systemName: "pencil")
                    }
                    .tint(.blue)
                }
            }
            .onMove { indexSet, index in
                viewModel.items.move(fromOffsets: indexSet, toOffset: index)
                Task {
                    await viewModel.updateIndexes()
                }
            }
        }
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
                        Image(systemName: "plus")
                    }
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
        .overlay(alignment: .center, content: {
            if !viewModel.loading && viewModel.items.count == 0 {
                EmptyMessageView(msg: "No categories were added to your store yet !")
            } else if viewModel.loading {
                ProgressView()
            }
        })
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

struct MyDropDelegate : DropDelegate {
    
    let item : Category
    @Binding var items : [Category]
    @Binding var draggedItem : Category?
    var onMoved:(() -> ())?
    
    func performDrop(info: DropInfo) -> Bool {
        return true
    }
    
    func dropEntered(info: DropInfo) {
        guard let draggedItem = self.draggedItem else {
            return
        }
        
        if draggedItem != item {
            let from = items.firstIndex(of: draggedItem)!
            let to = items.firstIndex(of: item)!
            
            withAnimation(.default) {
                self.items.move(fromOffsets: IndexSet(integer: from), toOffset: to > from ? to + 1 : to)
                if onMoved != nil { onMoved!() }
            }
        }
    }
}

struct StoreCategories_Previews: PreviewProvider {
    static var previews: some View {
        StoreCategories(store: Store.example())
    }
}
