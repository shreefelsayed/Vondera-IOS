//
//  Paytab.swift
//  Vondera
//
//  Created by Shreif El Sayed on 31/10/2023.
//

import SwiftUI

struct VPaySettings: View {
    @State var active = true
    @ObservedObject var user = UserInformation.shared
    
    
    @Environment(\.presentationMode) private var presentationMode
    @State var saving = false
    @State var msg:String?
    
    var body: some View {
        List {
            Toggle("Default Payment Gateway", isOn: $active)
            
            Text("V Pay is a payment gateway connected to your vondera account, it's created by us, this is no setup needed")
                .font(.caption)
        }
        .task {
            if let vPay = user.user?.store?.paymentOptions?.vPay {
                active = vPay.selected ?? true
            }
        }
        .willProgress(saving: saving)
        .navigationTitle("V Pay")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Update") {
                    connect()
                }
                
                Link(destination: URL(string: "https://www.youtube.com/watch?v=n_r5XrV38ww&t=3s&pp=ygUHVm9uZGVyYQ%3D%3D")!) {
                    Text("Help")
                }
            }
        }
    }
    
    func connect() {
        Task {
            var data = [
                "paymentOptions.vPay.gateway" : true,
                "paymentOptions.vPay.selected" : active,
            ]
            
            if active {
                data["paymentOptions.paymob.selected"] = false
                data["paymentOptions.paytabs.selected"] = false
                data["paymentOptions.kashier.selected"] = false
                data["paymentOptions.myFatoorah.selected"] = false
            }
            
            if let storeId = user.user?.storeId {
                saving = true
                Task {
                    try? await StoresDao().update(id:storeId, hashMap:data)
                    DispatchQueue.main.async {
                        UserInformation.shared.user?.store?.paymentOptions?.vPay?.gateway = true
                        UserInformation.shared.user?.store?.paymentOptions?.vPay?.selected = active
                        UserInformation.shared.updateUser()
                        saving = false
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}
