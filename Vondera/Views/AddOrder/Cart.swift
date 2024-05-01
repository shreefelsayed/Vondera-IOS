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
            
            await getCartItems()
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
        guard let storeId = UserInformation.shared.user?.storeId else { return }
        
        self.isLoading = true
        
        list.removeAll()
        
        do {
            for item in  CartManager().getCart() {
                let product = try await ProductsDao(storeId: storeId).getProduct(id: item.productId)
                guard let product = product else { continue }
                let obj = product.mapToOrderProduct(q: item.quantity, varient: item.hashMap, savedId: item.randomId)
                list.append(obj)
                print("Added item \(obj.name) to cart")
            }
        } catch {
            ToastManager.shared.showToast(msg: error.localizedDescription.localize(), toastType: .error)
        }
        
        self.isLoading = false
    }
}


struct Cart: View {
    @State var myUser = UserInformation.shared.getUser()
    @State var shipping:Bool = true
    @StateObject var viewModel = CartViewModel()
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        VStack {
            List {
                ForEach($viewModel.list, id: \.savedItemId) { item in
                    CartCard(orderProduct: item)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                Task {
                                    await viewModel.deleteItem(item.wrappedValue)
                                }
                            } label: {
                                Image(systemName: "trash.fill")
                            }
                        }
                        .id(item.wrappedValue.savedItemId)
                }
            }
            .listStyle(.plain)
            
            // MARK : Pricing
            if !viewModel.list.isEmpty {
                VStack(alignment: .center) {
                    VStack (alignment: .leading) {
                        HStack {
                            Text("Total (\(viewModel.totalItems)) items")
                            
                            Spacer()
                            
                            Text("EGP \(viewModel.totalPrice)")
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
                    .ignoresSafeArea()
                }
            }
        }
        .padding()
        .background(Color.background)
        .willLoad(loading: viewModel.isLoading)
        .overlay {
            if viewModel.list.isEmpty && !viewModel.isLoading {
                EmptyMessageWithResource(imageResource: .emptyCart, msg: "You haven't added any products to your cart yet !")
            }
        }
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
        .navigationTitle("Cart")
    }
}

struct Cart_Previews: PreviewProvider {
    static var previews: some View {
        Cart()
    }
}
