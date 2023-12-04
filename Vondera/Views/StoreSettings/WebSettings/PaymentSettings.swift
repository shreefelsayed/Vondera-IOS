//
//  PaymentSettings.swift
//  Vondera
//
//  Created by Shreif El Sayed on 31/10/2023.
//

import SwiftUI

struct PaymentSettings: View {
    @ObservedObject var user = UserInformation.shared
    @State var cod = true
    //@State var disableCOD = true
    var body: some View {
        List {
            Toggle("Cash on Delivery", isOn: $cod)
                .onChange(of: cod) { newValue in
                    updateCod(newValue)
                }
                .disabled(user.user?.store?.paymentOptions?.mustEnableCOD() ?? true)
            
            NavigationLink("Paytabs Gateway") {
                Paytab()
            }
            
            NavigationLink("Paymob Gateway") {
                PaymobSettings()
            }
        }
        .navigationTitle("Payment Settings")
        .task {
            if let cashSelected = user.user?.store?.paymentOptions?.cash?.selected {
                cod = cashSelected
            }
            
            /*if let paymentOptions = user.user?.store?.paymentOptions {
                disableCOD = !paymentOptions.mustEnableCOD()
            }*/
        }
    }
    
    func updateCod(_ value:Bool) {
        let data = [
            "paymentOptions.cash.selected" : value,
            "paymentOptions.cash.gateway" : false
        ]
        
        if let storeId = user.user?.storeId {
            Task {
                try? await StoresDao().update(id:storeId, hashMap:data)
                DispatchQueue.main.async {
                    UserInformation.shared.user?.store?.paymentOptions?.cash?.selected = value
                    UserInformation.shared.updateUser()
                }
            }
        }
    }
}

#Preview {
    PaymentSettings()
}
