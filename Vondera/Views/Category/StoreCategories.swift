//
//  StoreCategories.swift
//  Vondera
//
//  Created by Shreif El Sayed on 25/06/2023.
//

import SwiftUI
import AlertToast
import AdvancedList

struct StoreCategories: View {
    var store:Store
    @ObservedObject var viewModel:StoreCategoriesViewModel
    @State private var draggingIndex: Int?
    @State var draggedItem : Category?
    
    init(store: Store) {
        self.store = store
        self.viewModel = StoreCategoriesViewModel(store: store)
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            if !viewModel.items.isEmpty {
                LazyVStack {
                    Text("Swipe right on any category to edit it, and you can drag and drop to re arrange categories based on your needs.")
                        .font(.caption)
                        .padding(.vertical, 6)
                    
                    ForEach(viewModel.items) { item in
                        CategoryLinear(category: item, onClick: {
                        })
                        .onDrag({
                            self.draggedItem = item
                            return NSItemProvider(item: nil, typeIdentifier: item.id)
                        })
                        .onDrop(of: [.text], delegate: MyDropDelegate(item: item, items: $viewModel.items, draggedItem: $draggedItem, onMoved: {
                            Task {
                                await viewModel.updateIndexes()
                            }
                        }))
                        .mySwipeAction(color: .blue, icon: "pencil" ) { // custom color + icon
                            print("Show Edit dialog")
                        }
                    }
                }
            }
            
        }
        .animation(.default, value: viewModel.items)
        .padding()
        .navigationTitle("Categories")
        .toolbar{
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: CreateCategory(storeId: store.ownerId, listCategories: $viewModel.items)) {
                    Image(systemName: "plus")
                }
            }
        }
        .overlay(alignment: .center, content: {
            EmptyMessageView(msg: "No categories were added to your store yet !")
                .isHidden(!viewModel.items.isEmpty)
        })
        .navigationBarTitleDisplayMode(.large)
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
