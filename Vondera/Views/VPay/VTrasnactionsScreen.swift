//
//  VTrasnactionsScreen.swift
//  Vondera
//
//  Created by Shreif El Sayed on 31/12/2023.
//

import SwiftUI
import FirebaseFirestore

struct VTrasnactionsScreen: View {
    @State private var items = [VTransaction]()
    @State private var isLoading = false
    @State private var canLoadMore = true
    @State private var lastSnapshot:DocumentSnapshot?
    
    var body: some View {
        List {
            ForEach(items) { item in
                NavigationLink {
                    TransactionDetails(transactionId: item.id)
                } label: {
                    TransactionCard(item:item)
                }
                .buttonStyle(.plain)

                
                
                if canLoadMore && items.last?.id == item.id {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                    .onAppear {
                        loadItems()
                    }
                }
            }
        }
        .listStyle(.plain)
        .scrollIndicators(.hidden)
        .task {
            loadItems()
        }
        .refreshable {
            await refreshItems()
        }
        .overlay(alignment: .center) {
            if isLoading && items.isEmpty {
                ProgressView()
            } else if !isLoading && items.isEmpty {
                VStack {
                    Spacer()
                    EmptyMessageView(systemName: "arrow.left.arrow.right", msg: "No transactions were made yet by your clients")
                    Spacer()
                }
            }
        }
        
        
    }
    
    func loadItems() {
        Task {
            if let storeId = UserInformation.shared.user?.storeId {
                guard !isLoading && canLoadMore else {
                    return
                }
                
                do {
                    self.isLoading = true
                    let result = try await VTransactionsDao(storeId: storeId).getAll(lastSnapshot: lastSnapshot)
                    self.lastSnapshot = result.1
                    self.items.append(contentsOf: result.0)
                    self.canLoadMore = !result.0.isEmpty
                    
                } catch {
                    print(error.localizedDescription)
                }
                
                self.isLoading = false
            }
        }
    }
    
    func refreshItems() async {
        self.canLoadMore = true
        self.lastSnapshot = nil
        self.items.removeAll()
        loadItems()
    }
}

struct TransactionCard : View {
    var item:VTransaction
    var body: some View {
        HStack(alignment: .center) {
            Image(.btnTransactions)
            
            VStack(alignment:.leading) {
                Text("#\(item.orderId)")
                    .bold()
                
                Text(item.date.toString())
                    .font(.caption)
            }
            
            Spacer()
            
            Text("EGP \(Int(item.amount_after_rate))")
                .bold()
                .foregroundStyle(Color.accentColor)
        }
        
    }
}

#Preview {
    VTrasnactionsScreen()
}
