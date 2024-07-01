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
    
    init() {
        Task { await getCounters() }
    }
    
    private func getCounters() async {
        isLoading = true
        do {
            let pCount = try await Firestore.firestore().collectionGroup("vPayouts").whereField("statue", isEqualTo: "Pending").getCount()
            
            let sCount = try await Firestore.firestore().collection("stores").getCount()
            
            let aCount =  try await Firestore.firestore().collection("stores")
                .order(by: "vPayWallet", descending: true).whereField("vPayWallet", isGreaterThan: 5).getCount()
            
            let tCount = try await AdminTransDao().getTodayTrans().getCount()
            
            DispatchQueue.main.async {
                self.trasnsactionCount = tCount
                self.payoutRequestCount = pCount
                self.storesCount = sCount
                self.activeCount = aCount
                
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
    }
}

#Preview {
    AdminMain()
}
