//
//  TransactionDetails.swift
//  Vondera
//
//  Created by Shreif El Sayed on 28/03/2024.
//

import SwiftUI

struct TransactionDetails: View {
    var transactionId:String
    @State var transaction:VTransaction?
    @State var showOrder = false
    @State var isLoading = false
    
    var body: some View {
        List {
            if let transaction = transaction {
                Section {
                    HStack {
                        Text("Transaction")
                        
                        Spacer()
                        
                        Text("\(transactionId)")
                            .lineLimit(1)
                            .font(.caption)
                        
                        Image(systemName: "doc.on.clipboard.fill")
                            .onTapGesture {
                                CopyingData().copyToClipboard(transactionId)
                            }
                    }
                    
                    HStack {
                        Text("Transaction Date")
                        
                        Spacer()
                        
                        Text("\(transaction.date.toString())")
                    }
                    
                    HStack {
                        Text("Order id")
                        
                        Spacer()
                        
                        Text("\(transaction.orderId)")
                        
                        Image(systemName: "chevron.right")
                    }
                    .onTapGesture {
                        showOrder.toggle()
                    }
                }
                
                Section {
                    HStack {
                        Text("Transaction amount")
                        
                        Spacer()
                        
                        Text("EGP \(Int(transaction.amount))")
                    }
                    
                    HStack {
                        Text("Commission")
                        
                        Spacer()
                        
                        Text("EGP \(Int(transaction.amount - transaction.amount_after_rate))")
                            .foregroundStyle(.red)
                    }
                    
                    HStack {
                        Text("Withdrawable amount")
                        
                        Spacer()
                        
                        Text("EGP \(Int(transaction.amount_after_rate))")
                            .foregroundStyle(.green)
                    }
                    
                }
            }
        }
        .willLoad(loading: isLoading)
        .task {
            await fetchData()
        }
        .navigationTitle("Transaction details")
        .navigationDestination(isPresented: $showOrder) {
            if let orderId = transaction?.orderId {
                OrderDetailLoading(id: orderId)
            }
        }
    }
    
    private func fetchData() async {
        guard let storeId = UserInformation.shared.user?.storeId else {
            return
        }
        
        self.isLoading = true
        
        do {
            let result = try await VTransactionsDao(storeId: storeId).getTransaction(id: transactionId)
            guard let result = result else {
                return
            }
            
            DispatchQueue.main.async {
                self.transaction = result
                self.isLoading = false
            }
        } catch {
            CrashsManager().addLogs(error.localizedDescription, "Transaction Details")
            ToastManager.shared.showToast(msg: error.localizedDescription.localize(), toastType: .error)
        }
    }
}

#Preview {
    TransactionDetails(transactionId: "")
}
