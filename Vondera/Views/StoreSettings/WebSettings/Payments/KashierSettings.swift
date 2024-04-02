//
//  Paytab.swift
//  Vondera
//
//  Created by Shreif El Sayed on 31/10/2023.
//

import SwiftUI

struct KashierSettings: View {
    @State var mId = ""
    @State var apiKey = ""
    @State var active = true
    @ObservedObject var user = UserInformation.shared
    
    var signLink = "https://www.kashier.io"
    
    @Environment(\.presentationMode) private var presentationMode
    @State var saving = false
    @State var msg:String?
    
    var body: some View {
        List {
            FloatingTextField(title: "Merchant Id", text: $mId, caption: "This is the Merhcanit id found in your dashboard", required: true)
            
            FloatingTextField(title: "API Key", text: $apiKey, caption: "The API Key found in your dashboard / integrations / payment key", required: true, keyboard: .default)
            
            Toggle("Default Payment Gateway", isOn: $active)
            
            
            Text("Don't have a Kashier account ? Sign Up now !")
                .foregroundColor(Color.accentColor)
                .multilineTextAlignment(.center)
                .onTapGesture {
                    if let url = URL(string: signLink) {
                        UIApplication.shared.open(url)
                    }
                }
        }
        .task {
            if let kashier = user.user?.store?.paymentOptions?.kashier {
                mId = kashier.mId ?? ""
                apiKey = kashier.apiKey ?? ""
                active = kashier.selected ?? false
            }
        }
        .willProgress(saving: saving)
        .navigationTitle("Kashier")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Connect") {
                    connect()
                }
            }
        }
    }
    
    func connect() {
        guard !mId.isBlank, !apiKey.isBlank else {
            msg = "Please fill the required data"
            return
        }
        
        Task {
            var data = [
                "paymentOptions.kashier.mId" : mId,
                "paymentOptions.kashier.apiKey" : apiKey,
                "paymentOptions.kashier.selected" : active,
                "paymentOptions.kashier.connected" : true,
                "paymentOptions.kashier.gateway" : true,
            ]
            
            if active {
                data["paymentOptions.paytabs.selected"] = false
                data["paymentOptions.paymob.selected"] = false
                data["paymentOptions.vPay.selected"] = false
                data["paymentOptions.myFatoorah.selected"] = false
            }
            
            if let storeId = user.user?.storeId {
                saving = true
                Task {
                    try? await StoresDao().update(id:storeId, hashMap:data)
                    DispatchQueue.main.async {
                        UserInformation.shared.user?.store?.paymentOptions?.kashier?.selected = active
                        UserInformation.shared.user?.store?.paymentOptions?.kashier?.mId = mId
                        UserInformation.shared.user?.store?.paymentOptions?.kashier?.apiKey = apiKey
                        UserInformation.shared.updateUser()
                        saving = false
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    Paytab()
}
