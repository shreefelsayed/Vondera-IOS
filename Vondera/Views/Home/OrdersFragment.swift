//
//  OrdersFragment.swift
//  Vondera
//
//  Created by Shreif El Sayed on 20/10/2023.
//

import SwiftUI


class OrdersFragmentViewModel: ObservableObject {
    @Published var itemsLatest = [Order]()
    @Published var itemsUpdated = [Order]()
    @Published var isLoading = true
    
    init() {
        Task {
            await getContent()
        }
    }
    
    func getContent() async {
        if let storeId = UserInformation.shared.user?.storeId {
            do {
                let added = try await OrdersDao(storeId: storeId).getOrdersSortedBy(index: "date")
                let updated = try await OrdersDao(storeId: storeId).getOrdersSortedBy(index: "lastUpdated")
            
                DispatchQueue.main.async {
                    self.itemsLatest = added
                    self.itemsUpdated = updated
                    self.isLoading = false
                    print("Data loaded")
                }
            } catch {
                print("Order error \(error)")
            }
        } else {
            print("Couldn't find a store id")
        }
    }
}


struct OrdersFragment: View {
    @ObservedObject var myUser = UserInformation.shared
    @StateObject var vm = OrdersFragmentViewModel()
   
    var body: some View {
        VStack {
            if let user = myUser.user {
                //TOOLBAR
                HStack {
                    Text("Orders")
                        .font(.title)
                        .bold()
                    
                    Spacer()
                    
                    HStack {
                        NavigationLink(destination: AddToCart()) {
                            Image(systemName: "plus.app")
                        }
                        
                        NavigationLink(destination: OrderSearchView(storeId: user.storeId)) {
                            Image(systemName: "magnifyingglass.circle.fill")
                        }
                        
                    }
                    .buttonStyle(.plain)
                    .font(.title)
                    .bold()
                    
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                
                if let hiddenCount = UserInformation.shared.user?.store?.hiddenOrders, hiddenCount > 0 {
                    HStack {
                        Spacer()
                        
                        Text("You have \(hiddenCount) orders, renew your plan to unlock them")
                            .bold()
                            .font(.caption)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                        
                        Spacer()
                    }
                    .padding()
                    .background(.red.opacity(0.2))
                    .cornerRadius(8)
                    .padding()
                }
                
                List {
                    // MARK : 3 Cards with counters
                    Section {
                        NavigationLink(destination: FullfillOrdersFragment()) {
                            HStack {
                                Label(
                                    title: { Text("Orders to fulfill").bold() },
                                    icon: { Image(.btnNewOrders) }
                                )
                                
                                Spacer()
                                
                                Text("\(user.store?.ordersCountObj?.fulfill ?? 0)")
                            }
                        }
                        
                        if user.accountType != "Marketing" {
                            NavigationLink(destination: NewAllOrders()) {
                                HStack {
                                
                                    Label(
                                        title: { Text("All Orders").bold() },
                                        icon: { Image(.btnOrders) }
                                    )

                                    
                                    Spacer()
                                    
                                    Text("\(user.store?.ordersCount ?? 0)")
                                }
                            }
                        }
                        
                                                
                        NavigationLink(destination: UserOrders()) {
                            HStack {
                                Label(
                                    title: { Text("My Orders").bold() },
                                    icon: { Image(.btnOrders) }
                                )
                                
                                Spacer()
                                
                                Text("\(user.ordersCount ?? 0)")
                            }
                        }
                        
                        NavigationLink(destination: StoreCouriers()) {
                            HStack {
                                Label(
                                    title: { Text("With Couriers").bold() },
                                    icon: { Image(.btnShipping) }
                                )
                                
                                Spacer()
                                
                                Text("\(user.store?.ordersCountObj?.OutForDelivery ?? 0)")
                            }
                        }
                        
                    }
                    .buttonStyle(.plain)
                    .listRowSpacing(4)
                    
                    
                    // MARK : Latest Orders
                    if !vm.itemsLatest.isEmpty {
                        Section("Latest Orders") {
                            ForEach($vm.itemsLatest.indices, id: \.self) { index in
                                OrderCard(order: $vm.itemsLatest[index])
                            }
                        }
                        .listStyle(.plain)
                    }
                    
                    if !vm.itemsUpdated.isEmpty {
                        Section("Latest Updated") {
                            ForEach($vm.itemsUpdated.indices, id: \.self) { index in
                                OrderCard(order: $vm.itemsUpdated[index])
                            }
                        }
                        .listStyle(.plain)
                    }
                    
                }
                .scrollIndicators(.hidden)
                .listRowSeparator(.hidden)
            }
        }
        .isHidden(vm.isLoading)
        .overlay {
            ProgressView()
                .isHidden(!vm.isLoading)
        }
        .overlay {
            if !vm.isLoading && vm.itemsLatest.isEmpty && vm.itemsUpdated.isEmpty {
                EmptyMessageViewWithButton(systemName: "bag.badge.questionmark", msg: "Your store has no orders") {
                    NavigationLink {
                        AddToCart()
                    } label: {
                        Text("Add your first order")
                    }
                    .buttonStyle(.bordered)

                }
            }
        }
        .refreshable {
            await getUser()
            await vm.getContent()
        }
    }
    
    func getUser() async {
        do {
            if let id = myUser.user?.id {
                if let user = try await UsersDao().getUserWithStore(userId: id) {
                    DispatchQueue.main.async {
                        self.myUser.user = user
                    }
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
 
}

#Preview {
    OrdersFragment()
}
