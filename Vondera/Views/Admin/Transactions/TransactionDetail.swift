//
//  TransactionDetail.swift
//  Vondera
//
//  Created by Shreif El Sayed on 28/06/2024.
//

import SwiftUI

struct TransactionDetail: View {
    var transaction:AdminTransaction
    
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
        }
        .navigationTitle("Transaction Detail")
    }
}

