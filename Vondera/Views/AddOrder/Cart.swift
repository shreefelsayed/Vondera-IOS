//
//  Cart.swift
//  Vondera
//
//  Created by Shreif El Sayed on 29/06/2023.
//

import SwiftUI

class CartViewModel : ObservableObject {
    @Published var myUser = UserInformation.shared.getUser()
    @Published var list = [OrderProductObject]()
    @Published var isLoading = false

    
    init() {
        Task {
            if let user = UserInformation.shared.getUser() {
                self.myUser = user
            }
        }
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
        CartManager().clearCart()
        
        // --> Remove list
        self.list.removeAll()
    }
    
    func deleteItem(_ item:OrderProductObject) async {
        let index = list.firstIndex {$0.productId == item.productId}
        
        // --> Remove from saved Item
        CartManager().removeItemFromCart(randomId: item.savedItemId, hashMap: item.hashVaraients)
        
        // --> Remove from list
        if let index = index {
            list.remove(at: index)
        }
    }
    
    func getCartItems() async {
        if let storeId = myUser?.storeId {
            let savedList =  CartManager().getCart()
            list.removeAll()
            self.isLoading = true
            
            
            for item in savedList {
                let exist = try? await ProductsDao(storeId: storeId).productExist(id: item.productId)
                if (exist ?? false) {
                    let prod = try! await ProductsDao(storeId: storeId).getProduct(id: item.productId)
                    let obj = prod!.mapToOrderProduct(q:item.quantity, varient: item.hashMap, savedId: item.randomId)
                    list.append(obj)
                }
            }
            
            self.isLoading = false
        }
        
    }
}


struct Cart: View {
    @State var myUser = UserInformation.shared.getUser()
    @State var shipping:Bool = true
    @ObservedObject var viewModel = CartViewModel()
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        VStack {
            List {
                ForEach($viewModel.list, id: \.self) { item in
                    CartAdapter(orderProduct: item)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                Task {
                                    await viewModel.deleteItem(item.wrappedValue)
                                }
                            } label: {
                                Image(systemName: "trash.fill")
                            }
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                }
            }
            .listStyle(.plain)
            .padding()
            
            
            // MARK : Pricing
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
                        
                        if myUser != nil && !(myUser!.store!.onlyOnline ?? false) {
                            
                            Toggle("This order require shipping", isOn: $shipping)
                        }
                        
                        if !viewModel.list.isEmpty {
                            if let storeId = viewModel.myUser?.storeId {
                                NavigationLink(destination: CheckOut(storeId: storeId, listItems: viewModel.list, shipping: shipping, onSubmited: {
                                    
                                    self.presentationMode.wrappedValue.dismiss()
                                })) {
                                    Text("Check out")
                                        .frame(maxWidth: .infinity)
                                        .multilineTextAlignment(.center)
                                        .bold()
                                }
                                .padding(.top, 12)
                            }
                        }
                        
                        
                    }
                    .padding()
                    .ignoresSafeArea()
                    .background(Color.background)
                }
            }
            
        }
        .onAppear {
            Task {
                self.myUser = UserInformation.shared.getUser()
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
}

struct Cart_Previews: PreviewProvider {
    static var previews: some View {
        Cart()
    }
}
