//
//  AdminMain.swift
//  Vondera
//
//  Created by Shreif El Sayed on 28/06/2024.
//

import SwiftUI
import FirebaseFirestore

class AdminMainViewModel : ObservableObject {
    @Published var isLoading = false
    
    @Published var trasnsactionCount = 0
    @Published var payoutRequestCount = 0
    @Published var storesCount = 0
    @Published var activeCount = 0
    @Published var withHiddenOrders = 0
    
    @Published var currentlySub = 0
    @Published var stopedSub = 0
    
    init() {
        Task { await getCounters() }
    }
    
    func getCounters() async {
        isLoading = true
        do {
            let pCount = try await Firestore.firestore().collectionGroup("vPayouts").whereField("statue", isEqualTo: "Pending").getCount()
            
            let sCount = try await Firestore.firestore().collection("stores").getCount()
            
            let hCount = try await Firestore.firestore().collection("stores")
                .whereField("hiddenOrders", isGreaterThan: 0)
                .getCount()
            
            let stopped = try await Firestore.firestore().collection("stores")
                .whereField("renewCount", isGreaterThan: 0)
                .whereField("storePlanInfo.planId", isEqualTo: "free")
                .getCount()
            
            let still = try await Firestore.firestore().collection("stores")
                .whereField("renewCount", isGreaterThan: 0)
                .whereField("storePlanInfo.planId", notIn: ["OnDemand","free"])
                .getCount()
            
            let aCount =  try await Firestore.firestore().collection("stores")
                .order(by: "vPayWallet", descending: true)
                .whereField("vPayWallet", isGreaterThan: 5)
                .getCount()
            
            let tCount = try await AdminTransDao().getTodayTrans().getCount()
            
            DispatchQueue.main.async {
                self.trasnsactionCount = tCount
                self.payoutRequestCount = pCount
                self.storesCount = sCount
                self.activeCount = aCount
                self.withHiddenOrders = hCount
                
                self.currentlySub = still
                self.stopedSub = stopped
                self.isLoading = false
            }
        } catch {
            print(error)
        }
    }
}

struct AdminMain: View {
    @StateObject private var viewModel = AdminMainViewModel()
    
    @State private var count = 0
    @State private var showSavedItems = false

    var body: some View {
        List {
            Text("Welcome Back \(UserInformation.shared.user?.name ?? "User") !")
                .bold()
            
            Section("Stores") {
                NavigationLink {
                    StoresScreen()
                } label: {
                    HStack {
                        Text("Stores")
                        Spacer()
                        
                        if viewModel.storesCount > 0 {
                            Text("\(viewModel.storesCount)")
                                
                        }
                    }
                }
                
                NavigationLink {
                    SubscribedStoresScreen()
                } label: {
                    HStack {
                        Text("Currently Subscribed")
                        Spacer()
                        
                        if viewModel.currentlySub > 0 {
                            Text("\(viewModel.currentlySub)")
                        }
                    }
                }
                
                NavigationLink {
                    HiddenOrdersStoreScreen()
                } label: {
                    HStack {
                        Text("With Hidden Orders")
                        Spacer()
                        
                        if viewModel.withHiddenOrders > 0 {
                            Text("\(viewModel.withHiddenOrders)")
                        }
                    }
                }
                
                NavigationLink {
                    StopedSubscribeStores()
                } label: {
                    HStack {
                        Text("Stoped Subscribing")
                        Spacer()
                        
                        if viewModel.stopedSub > 0 {
                            Text("\(viewModel.stopedSub)")
                        }
                    }
                }
                
                NavigationLink("Send Notification") {
                    SendNotificationScreen()
                }
            }
            
            Section("Plans") {
                NavigationLink("Discount Codes") {
                    DiscountCodesScreen()
                }
            }
            
            Section("Tools") {
                NavigationLink("Create Tips") {
                    CreateTipsScreen()
                }
                
                NavigationLink {
                    VonderaTransactionsScreen()
                } label: {
                    HStack {
                        Text("Transactions")
                        Spacer()
                        
                        if viewModel.trasnsactionCount > 0 {
                            Text("\(viewModel.trasnsactionCount)")
                
                        }
                    }
                }
                
                
                NavigationLink("Statistics") {
                    VonderaStaticsScreen()
                }
            }
            
            Section("VPay") {
                NavigationLink {
                    AdminPayoutsScreen()
                } label: {
                    HStack {
                        Text("Payout Requests")
                        Spacer()
                        
                        if viewModel.payoutRequestCount > 0 {
                            Text("\(viewModel.payoutRequestCount)")
                            
                        }
                    }
                }
                
                
                NavigationLink {
                    AdminWalletsScreen()
                } label: {
                    HStack {
                        Text("Active Wallets")
                        Spacer()
                        
                        if viewModel.activeCount > 0 {
                            Text("\(viewModel.activeCount)")
            
                        }
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Menu {
                    NavigationLink("Account Settings") {
                        EditInfoView()
                    }
                    
                    NavigationLink("Change App Language") {
                        AppLanguage()
                    }
                    
                    NavigationLink("About App") {
                        AboutAppView()
                    }
                    
                    if count > 0 {
                        Button("Switch Account") {
                            withAnimation {
                                showSavedItems.toggle()
                            }
                        }
                    }
                    
                    Button("Log out", role: .destructive) {
                        Task { await AuthManger().logOut() }
                    }
                    
                    
                } label: {
                    Image(systemName: "gearshape.fill")
                }

            }
            
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    StoresSearchScreen()
                } label: {
                    Image(systemName: "magnifyingglass.circle")
                }
            }
        }
        .navigationTitle("Admin Dashboard")
        .task {
            count = SavedAccountManager().getAllUsers().count
        }
        .sheet(isPresented: $showSavedItems, content: {
            SwitchAccountView(show: $showSavedItems)
        })
        .willLoad(loading: viewModel.isLoading)
        .refreshable {
            await viewModel.getCounters()
        }
    }
}

#Preview {
    AdminMain()
}
