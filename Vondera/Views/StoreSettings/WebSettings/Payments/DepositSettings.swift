//
//  DepositSettings.swift
//  Vondera
//
//  Created by Shreif El Sayed on 02/12/2023.
//

import SwiftUI
import AlertToast

struct DepositSettings: View {
    @State private var depositAmount = 0
    @State private var active = false
    
    @State private var msg:String?
    @State private var saving = false
    
    @State private var canAddDeposit = false
    
    var body: some View {
        List {
            FloatingTextField(title: "Deposit amount", text: .constant(""), caption: "This is your Card live integration id from Paymob Developer Page", required: true, keyboard: .numberPad, isNumric: true, number: $depositAmount)
            
            VStack {
                Toggle("Require Deposit", isOn: $active)

                Text("Requiring a depoist will close the cash on delivery option, the deposit will be added to the order")
                    .font(.caption)
            }
            
            if !canAddDeposit {
                Text("In order to active this option, you need to add a payment gateway first")
                    .font(.body)
                    .foregroundStyle(.red)
            }
        }
        .task {
            if let depositDisabled = UserInformation.shared.user?.store?.paymentOptions?.mustEnableCOD() {
                self.canAddDeposit = !depositDisabled
            }
        }
        .willProgress(saving: saving)
        .toast(isPresenting: Binding(value: $msg), alert: {
            AlertToast(displayMode: .banner(.pop), type: .regular, title: msg)
        })
        .navigationTitle("Paymob")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Connect") {
                    connect()
                }
            }
        }
    }
    
    func connect() {
        
    }
}

#Preview {
    DepositSettings()
}
