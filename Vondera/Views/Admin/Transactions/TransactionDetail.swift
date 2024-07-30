//
//  TransactionDetail.swift
//  Vondera
//
//  Created by Shreif El Sayed on 28/06/2024.
//

import SwiftUI

struct TransactionDetail: View {
    var transaction:AdminTransaction
    @State private var user:UserData?
    
    var body: some View {
        List {
            Section {
                HStack {
                    Text("TRX ID")
                    
                    Spacer()
                    
                    Text(transaction.id)
                }
                
                HStack {
                    Text("Date")
                    
                    Spacer()
                    
                    Text(transaction.date.formatted())
                }
                
                HStack {
                    Text("Amount")
                    
                    Spacer()
                    
                    Text("EGP \(transaction.amount.toString())")
                }
                
                HStack {
                    Text("Method")
                    
                    Spacer()
                    
                    Text("\(transaction.method ?? "Admin")")
                }
                
                if let user = user {
                    HStack {
                        Text("By Admin")
                        
                        Spacer()
                        
                        Text(user.name)
                    }
                }
            }
            
            Section {
                HStack {
                    Text("Plan")
                    
                    Spacer()
                    
                    Text(transaction.planId ?? "Free")
                }
            }
            
            Section {
                HStack {
                    Text("Merchant Id")
                    
                    Spacer()
                    
                    Text(transaction.mId ?? "")
                }
                
                HStack {
                    Text("Store Id")
                    
                    Spacer()
                    
                    Text(transaction.uId ?? "")
                }
            }
            
            NavigationLink("Visit Store", destination: StoresProfileScreen(id: transaction.uId ?? ""))
        }
        .navigationTitle("Transaction Detail")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                let count = transaction.count ?? 0
                Text(count <= 1 ? "New TRX" : "Renewal TRX")
                    .foregroundStyle(count <= 1 ? .green : .yellow)
                    .bold()
            }
        }
        .task {
            await checkUser()
        }
    }
    
    private func checkUser() async {
        guard let method = transaction.method, let id = transaction.actionBy, method == "Admin", !id.isBlank else { return }
        
        do {
            let result = try await UsersDao().getUser(uId: id)
            guard let item = result.item else { return }
            
            DispatchQueue.main.async {
                self.user = item
            }
        } catch {
            print(error)
        }
    }
}

