//
//  EditOrderProducts.swift
//  Vondera
//
//  Created by Shreif El Sayed on 23/10/2023.
//

import SwiftUI
import AlertToast
import FirebaseFirestore

class EditOrderProductsVM: ObservableObject {
    @Published var cost = 0
    @Published var count = 0
    
    @Published var items = [OrderProductObject]() {
        didSet {
            count = items.getTotalQuantity()
            cost = items.getTotalPrice()
        }
    }
    
    // --> UI
    @Published var msg:LocalizedStringKey?
    @Published var isSaving = false
    
    // --> VARS
    @Published var myUser = UserInformation.shared.getUser()
    
    func addItem(product:StoreProduct, option:[String:String]) {
        let item = product.mapToOrderProduct(varient: option)
        self.items.append(item)
    }
    
    func save(_ order:Order) async -> Bool{
        guard !items.isEmpty else {
            return false
        }
        
        if let storeId = order.storeId {
            do {
                var hashMap = [String: Any]()
                hashMap["listProducts"] = try items.map { try Firestore.Encoder().encode($0) }
                try await OrdersDao(storeId: storeId).update(id: order.id, hashMap: hashMap)
                return true
            } catch {
                print(String(describing: error))
                return false
            }
        }
        
        return false
    }
}

struct EditOrderProducts: View {
    @Binding var order:Order
    @Binding var isPreseneted:Bool
    
    @State var addItemSheet = false
    @ObservedObject var viewModel = EditOrderProductsVM()
    
    var body: some View {
        VStack {
            List {
                Section {
                    ForEach($viewModel.items.indices, id: \.self) { index in
                        CartCard(orderProduct: $viewModel.items[index])
                            .listRowInsets(EdgeInsets())
                            .listRowSeparator(.hidden)
                    }
                    .onDelete { index in
                        viewModel.items.remove(atOffsets: index)
                    }
                } header: {
                    HStack {
                        Text("Order items")
                        
                        Spacer()
                        
                        Button("Add item") {
                            addItemSheet.toggle()
                        }
                    }
                }
            }
            .listStyle(.plain)
            .padding()
            
            
            // MARK : Pricing
            if !viewModel.items.isEmpty {
                VStack (alignment: .leading) {
                    HStack {
                        Text("Total Items")
                        
                        Spacer()
                        
                        Text("\(viewModel.count) Pieces")
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("Total Products price")
                        
                        Spacer()
                        
                        Text("\(viewModel.cost) LE")
                    }
                }
                .padding()
                .ignoresSafeArea()
                .background(Color.background)
            }
            
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    guard !viewModel.items.isEmpty else {
                        viewModel.msg = "You must add products to order"
                        return
                    }
                    
                    Task {
                        let success = await viewModel.save(order)
                        if success {
                            order.listProducts = viewModel.items
                            isPreseneted.toggle()
                        }
                    }
                }
                .disabled(viewModel.items.isEmpty || viewModel.isSaving)
            }
        }
        .task {
            if let items = order.listProducts {
                viewModel.items = items
            }
        }
        .toast(isPresenting: Binding(value: $viewModel.msg), alert: {
            AlertToast(displayMode: .banner(.pop), type: .regular, title: viewModel.msg?.toString())
        })
        .navigationTitle("Edit Products")
        .sheet(isPresented: $addItemSheet, content: {
            AddItemsToOrder { product, options in
                viewModel.addItem(product: product, option: options)
            }
        })
    }
}

struct AddItemsToOrder : View {
    var onItemAdded:((StoreProduct, [String:String]) -> ())
    @State var items = [StoreProduct]()
    @State var searchText = ""
    @State var isLoading = false
    @State var selectedProduct:StoreProduct?
    
    var body: some View {
        ScrollView {
            VStack {
                // MARK : Items
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                    ForEach(Array($items.enumerated()), id: \.element.id) { i, product in
                        if product.wrappedValue.filter(searchText) {
                            ProductCard(product: product, showBuyButton: false)
                                .id(product.id)
                                .onTapGesture {
                                    self.selectedProduct = $items[i].wrappedValue
                                }
                        }
                    }
                }
                .padding(.horizontal, 12)
            }
        }
        .willLoad(loading: isLoading)
        .overlay {
            if items.isEmpty && isLoading {
                ProgressView()
            } else if items.isEmpty && !isLoading {
                EmptyMessageView(systemName: "tag.fill", msg: "No products are added to the store yet !")
            } else if !searchText.isBlank && items.filter({ $0.filter(searchText) }).isEmpty {
                SearchEmptyView(searchText: searchText)
            }
        }
        .searchable(text: $searchText, prompt: Text("Search \($items.count) Products"))
        .refreshable {
            searchText = ""
            await getData()
        }
        .task {
            isLoading = true
            await getData()
        }
        .navigationTitle("Add Products")
        .sheet(item: $selectedProduct) { prod in
            NavigationStack {
                ProductBuyingSheet(product: .constant(prod), onAddedToCard: { product, options in
                    onItemAdded(product, options)
                })
            }
        }
    }
    
    func getData() async {
        do {
            if let storeId = UserInformation.shared.getUser()?.storeId {
                let items = try await ProductsDao(storeId: storeId).getAll(sort: "name")
                DispatchQueue.main.async {
                    self.items = items
                    self.isLoading = false
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
}
