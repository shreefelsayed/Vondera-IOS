//
//  AdminWalletsScreen.swift
//  Vondera
//
//  Created by Shreif El Sayed on 28/06/2024.
//

import SwiftUI

class AdminWalletsScreenVM : ObservableObject {
    @Published var isLoading = false
    @Published var items = [Store]()

    init() {
        Task {
            await fetchData()
        }
    }
    
    private func fetchData() async {
        isLoading = true
        
        do {
            let result = try await StoresDao().getStoresWithWallets()
            DispatchQueue.main.async {
                self.isLoading = false
                self.items = result
            }
        } catch {
            print(error)
        }
    }
}

struct AdminWalletsScreen: View {
    @StateObject private var viewModel = AdminWalletsScreenVM()
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                ForEach(viewModel.items, id: \.ownerId) { store in
                    VStack {
                        HStack {
                            StoreCard(store: store)
                            
                            Text("\(store.vPayWallet?.toString() ?? "0") LE")
                                .foregroundStyle(.red)
                                .font(.headline)
                                .bold()
                        }
                        
                        Divider()
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Wallets")
        .willLoad(loading: viewModel.isLoading)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Text("Total : \(viewModel.items.map({$0.vPayWallet ?? 0}).reduce(0, +).toString()) EGP")
            }
        }
        .overlay {
            if viewModel.items.isEmpty, !viewModel.isLoading {
                Text("No users have money in their wallets")
            }
        }
    }
}

#Preview {
    AdminWalletsScreen()
}
