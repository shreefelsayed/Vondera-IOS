//
//  Cart.swift
//  Vondera
//
//  Created by Shreif El Sayed on 29/06/2023.
//

import SwiftUI

class CartViewModel : ObservableObject {
    var storeId:String
    var productsDao:ProductsDao
    
    @Published var list = [OrderProductObject]()
    @Published var isLoading = false
    
    init(storeId: String) {
        self.storeId = storeId
        self.productsDao = ProductsDao(storeId: storeId)
    }
    
    var totalPrice : Int {
        var price = 0
        for item in list {
            price += (Int(item.price) * item.quantity)
        }
        
        return price
    }
    
    var totalItems : Int {
        var count = 0
        for item in list {
            count += item.quantity
        }
        
        return count
    }
    
    func clearList() async {
        // --> Clear local list
        await CartManager().clearCart()
        
        // --> Remove list
        self.list.removeAll()
    }
    
    func deleteItem(_ item:Binding<OrderProductObject>, _ indext:Int) async {
        // --> Remove from saved Item
        await CartManager().removeItemFromCart(randomId: item.savedItemId.wrappedValue!, hashMap: item.hashVaraients.wrappedValue!)
        
        // --> Remove from list
        list.remove(at: indext)
    }
    
    func getCartItems() async {
        let savedList = await CartManager().getCart()
        list.removeAll()
        self.isLoading = true
        
        
        for item in savedList {
            let exist = await productsDao.productExist(id: item.productId)
            if exist {
                let prod = try! await productsDao.getProduct(id: item.productId)
                let obj = prod!.mapToOrderProduct(q:item.quantity, varient: item.hashMap, savedId: item.randomId)
                list.append(obj)
            }
        }
        
        self.isLoading = false
    }
}


struct Cart: View {
    var storeId:String
    @ObservedObject var viewModel:CartViewModel
    
    init(storeId: String) {
        self.storeId = storeId
        viewModel = CartViewModel(storeId: storeId)
    }
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(viewModel.list.indices, id: \.self) { index in
                        let itemBinding = Binding<OrderProductObject>(
                            get: {
                                viewModel.list[index]
                            },
                            set: { newItem in
                                viewModel.list[index] = newItem
                            }
                        )
                        
                        CartAdapter(orderProduct: itemBinding) {
                            // On Item Deleted
                            Task {
                                await deleteItem(itemBinding, index)
                            }
                        }
                    }
                }
            }
            .padding()
            
            if !viewModel.list.isEmpty {
                VStack(alignment: .center) {
                    VStack (alignment: .leading) {
                        HStack {
                            Text("Total Items")
                            
                            Spacer()
                            
                            Text("\(viewModel.totalItems) Pieces")
                        }
                        
                        Divider()
                        
                        HStack {
                            Text("Total Products price")
                            
                            Spacer()
                            
                            Text("\(viewModel.totalPrice) LE")
                        }
                        

                        if !viewModel.list.isEmpty {
                            NavigationLink(destination: CheckOut(storeId: storeId, listItems: viewModel.list, shipping: true)) {
                                Text("Check out")
                                    .frame(maxWidth: .infinity)
                                    .multilineTextAlignment(.center)
                                    .bold()
                            }
                            .padding(.top, 12)
                        }
                        
                        
                    }
                    .padding()
                    .ignoresSafeArea()
                    .background(Color.white)
                }
            }
            
        }
        .onAppear {
            Task {
                await viewModel.getCartItems()
            }
        }
        .overlay(alignment: .center, content: {
            if viewModel.isLoading {
                ProgressView()
            } else if viewModel.list.isEmpty {
                EmptyMessageView(msg: "No items are in the cart")
            }
        })
        .toolbar{
            if !viewModel.list.isEmpty {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Text("Clear cart")
                        .foregroundColor(.red)
                        .onTapGesture {
                            Task {
                                await viewModel.clearList()
                            }
                        }
                }
            }
        }
        .navigationTitle("Cart 🛒")
    }
    
    func deleteItem(_ item:Binding<OrderProductObject>, _ index:Int) async {
        await viewModel.deleteItem(item,index)
    }
}

struct Cart_Previews: PreviewProvider {
    static var previews: some View {
        Cart(storeId: Store.Qotoofs())
    }
}
