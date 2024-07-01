//
//  VonderaTransactionsScreen.swift
//  Vondera
//
//  Created by Shreif El Sayed on 28/06/2024.
//

import SwiftUI
import FirebaseFirestore

class VonderaTransactionsScreenVM : ObservableObject {
    @Published var isLoading = false
    @Published var isFetching = false
    
    var lastDoc:DocumentSnapshot? = nil
    var hasMore = true
    var items = [AdminTransaction]()
    
    init() {
        Task {
            await fetch()
        }
    }
    
    func fetch() async {
        guard hasMore, !isLoading, !isFetching else { return }
        
        isLoading = lastDoc == nil
        isFetching = lastDoc != nil
        
        do {
            let result = try await AdminTransDao().getTransactions(lastDoc: lastDoc)
            DispatchQueue.main.async {
                self.hasMore = !result.0.isEmpty
                self.items.append(contentsOf: result.0)
                self.lastDoc = result.1
                self.isLoading = false
                self.isFetching = false
            }
        } catch {
            print(error)
        }
    }
}

struct VonderaTransactionsScreen: View {
    @StateObject private var viewModel = VonderaTransactionsScreenVM()
    
    var body: some View {
        List {
            ForEach(viewModel.items, id: \.id) { trans in
                VStack(alignment: .leading) {
                    NavigationLink {
                        TransactionDetail(transaction: trans)
                    } label: {
                        VStack(alignment: .leading) {
                            Text("\(trans.amount.toString()) EGP")
                                .font(.headline)
                                .bold()
                            
                            Text("Subscribed to the \(trans.planId ?? "") Plan")
                                .font(.body)
                            
                            Text("\(trans.date.formatted())")
                        }
                    }
                    
                    if trans.id == viewModel.items.last?.id && viewModel.hasMore {
                        ProgressView()
                            .onAppear {
                                Task { await viewModel.fetch() }
                            }
                    }
                }
            }
        }
        .willLoad(loading: viewModel.isLoading)
        .navigationTitle("Transactions")
    }
}

#Preview {
    VonderaTransactionsScreen()
}
