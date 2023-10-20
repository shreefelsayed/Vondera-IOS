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
                print(error.localizedDescription)
            }
        }
    }
}
struct OrdersFragment: View {
    @ObservedObject var myUser = UserInformation.shared
    @StateObject var vm = OrdersFragmentViewModel()
    
    @State var latestOrders = false
   

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
                    .font(.title2)
                    .bold()
                    
                }
                .padding()
                
                List {
                    // MARK : 3 Cards with counters
                    Section {
                        NavigationLink(destination: FullfillOrdersFragment()) {
                            HStack {
                                Label("Orders to fullfil", systemImage: "plus.diamond.fill")
                                    .bold()
                                
                                Spacer()
                                
                                Text("\(user.store?.ordersCountObj?.fulfill ?? 0)")
                            }
                        }
                        
                        
                        NavigationLink(destination: StoreAllOrders(storeId: user.storeId)) {
                            HStack {
                                Label("All Orders", systemImage: "basket.fill")
                                    .bold()
                                
                                Spacer()
                                
                                Text("\(user.store?.ordersCount ?? 0)")
                            }
                        }
                                                
                        NavigationLink(destination: UserOrders(id: user.id, storeId: user.storeId)) {
                            HStack {
                                Label("My Orders", systemImage: "person.crop.circle")
                                    .bold()
                                
                                Spacer()
                                
                                Text("\(user.ordersCount ?? 0)")
                            }
                        }
                        
                    }
                    .buttonStyle(.plain)
                    .listRowSpacing(4)
                    .listRowSeparator(.hidden)
                    
                    // MARK : Latest Orders
                    
                    if !vm.itemsLatest.isEmpty {
                        Section {
                            ForEach($vm.itemsLatest.indices, id: \.self) { index in
                                OrderCard(order: $vm.itemsLatest[index])
                            }
                        } header: {
                            HStack {
                                Text("Latest Orders")
                                    .font(.title3)
                                    .bold()
                                
                                Spacer()
                                
                                Text("See All")
                                    .underline()
                                    .foregroundStyle(.secondary)
                                    .onTapGesture {
                                        latestOrders.toggle()
                                    }
                            }
                        }
                    }
                    
                    
                    if !vm.itemsUpdated.isEmpty {
                        Section {
                            ForEach($vm.itemsUpdated.indices, id: \.self) { index in
                                OrderCard(order: $vm.itemsUpdated[index])
                            }
                        } header: {
                            Text("Latest Updated")
                                .font(.title3)
                                .bold()
                        }
                    }
                }
                .listStyle(.plain)
                .scrollIndicators(.hidden)
                .listRowSeparator(.hidden)
            }
           
        }
        .isHidden(vm.isLoading)
        .overlay {
            ProgressView()
                .isHidden(!vm.isLoading)
        }
        
        .refreshable {
            await getUser()
            await vm.getContent()
        }
        .navigationDestination(isPresented: $latestOrders) {
            if let storeId = myUser.user?.storeId {
                StoreAllOrders(storeId: storeId)
            }
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
