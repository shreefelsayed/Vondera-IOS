//
//  Paytab.swift
//  Vondera
//
//  Created by Shreif El Sayed on 31/10/2023.
//

import SwiftUI
import AlertToast

struct PaymobSettings: View {
    @State var integrationId = ""
    @State var iframe = ""
    @State var apiKey = ""
    @State var active = true
    @ObservedObject var user = UserInformation.shared
    
    let signLink = "https://www.paymob.com"
    let callback = "https://us-central1-brands-61c3d.cloudfunctions.net/commerce_paymob-onPaymobPaymentMade"
    
    @Environment(\.presentationMode) private var presentationMode
    @State var saving = false
    @State var msg:String?
    
    var body: some View {
        List {
            FloatingTextField(title: "Integration Id", text: $integrationId, caption: "This is your Card live integration id from Paymob Developer Page", required: true, keyboard: .numberPad)
            
            FloatingTextField(title: "IFrame id", text: $iframe, caption: "This is your iframe id, it should be located in paymob dashboard in the developer page", required: true, keyboard: .numberPad)
            
            FloatingTextField(title: "API Key", text: $apiKey, caption: "This is your api key should be found in the settings menu in your paymob dashboard", required: true, keyboard: .default)
            
            Toggle("Default Payment Gateway", isOn: $active)
            
            Text("Don't have a paymob account ? Sign Up now !")
                .font(.caption)
                .foregroundColor(Color.accentColor)
                .multilineTextAlignment(.center)
                .onTapGesture {
                    if let url = URL(string: signLink) {
                        UIApplication.shared.open(url)
                    }
                }
            
            // -- MARK : Link
            VStack (alignment: .center) {
                HStack {
                    Text(callback)
                        .font(.caption2)
                    
                    Spacer()
                    
                    Button {
                        CopyingData().copyToClipboard(callback)
                        msg = "Copied to clipboard"
                    } label: {
                        Image(systemName: "doc.on.doc.fill")
                            .font(.body)
                    }

                }
                
                Text("Edit your integration id and add this link to your Transaction processed callback")
                    .foregroundStyle(.red)
                    .font(.caption)
            }
            
        }
        .task {
            if let paymob = user.user?.store?.paymentOptions?.paymob {
                integrationId = paymob.integrationId ?? ""
                iframe = paymob.iframe ?? ""
                apiKey = paymob.apiKey ?? ""
                active = paymob.selected ?? false
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
        guard !integrationId.isBlank, !apiKey.isBlank, !iframe.isBlank else {
            msg = "Please fill the required data"
            return
        }
        
        Task {
            var data = [
                "paymentOptions.paymob.integrationId" : integrationId,
                "paymentOptions.paymob.iframe" : iframe,
                "paymentOptions.paymob.apiKey" : apiKey,
                "paymentOptions.paymob.selected" : active,
                "paymentOptions.paymob.connected" : true,
                "paymentOptions.paymob.gateway" : true,
            ]
            
            if active {
                data["paymentOptions.paytabs.selected"] = false
            }
            
            if let storeId = user.user?.storeId {
                saving = true
                Task {
                    try? await StoresDao().update(id:storeId, hashMap:data)
                    DispatchQueue.main.async {
                        UserInformation.shared.user?.store?.paymentOptions?.paymob?.selected = active
                        
                        UserInformation.shared.user?.store?.paymentOptions?.paymob?.iframe = iframe
                        UserInformation.shared.user?.store?.paymentOptions?.paymob?.integrationId = integrationId
                        UserInformation.shared.user?.store?.paymentOptions?.paymob?.apiKey = apiKey
                        
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
    PaymobSettings()
}
