//
//  Paytab.swift
//  Vondera
//
//  Created by Shreif El Sayed on 31/10/2023.
//

import SwiftUI
import AlertToast

struct MyFatoorahSettings: View {
    @State var apiKey = ""
    @State var active = true
    @ObservedObject var user = UserInformation.shared
    
    let signLink = "https://register.myfatoorah.com"
    let callback = "https://us-central1-brands-61c3d.cloudfunctions.net/myFatoorah-onPaymentMade"
    
    @Environment(\.presentationMode) private var presentationMode
    @State var saving = false
    @State var msg:String?
    
    var body: some View {
        List {
            FloatingTextField(title: "API Key", text: $apiKey, caption: "This is your api key should be found in the settings menu in your dashboard", required: true, keyboard: .default)
            
            Toggle("Default Payment Gateway", isOn: $active)
            
            Text("Don't have a MyFatoorah account ? Sign Up now !")
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
                    } label: {
                        Image(systemName: "doc.on.doc.fill")
                            .font(.body)
                    }

                }
                
                Text("Go to your dashboard/Integration Settings/Webhook \nAdd this link and disable Secret Key, and Check Transaction Status Changed")
                    .foregroundStyle(.red)
                    .font(.caption)
            }
            
        }
        .task {
            if let myFatoorah = user.user?.store?.paymentOptions?.myFatoorah {
                apiKey = myFatoorah.apiKey ?? ""
                active = myFatoorah.selected ?? false
            }
        }
        .willProgress(saving: saving)
        .toast(isPresenting: Binding(value: $msg), alert: {
            AlertToast(displayMode: .banner(.pop), type: .regular, title: msg)
        })
        .navigationTitle("My Fatoorah")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Connect") {
                    connect()
                }
                
                Link(destination: URL(string: "https://www.youtube.com/watch?v=ZdKC0c9NHxk&pp=ygUHVm9uZGVyYQ%3D%3D")!) {
                    Text("Help")
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                
            }
        }
        .withPaywall(accessKey: .payments, presentation: presentationMode)

        
    }
    
    func connect() {
        guard !apiKey.isBlank else {
            msg = "Please fill the required data"
            return
        }
        
        Task {
            var data = [
                "paymentOptions.myFatoorah.apiKey" : apiKey,
                "paymentOptions.myFatoorah.selected" : active,
                "paymentOptions.myFatoorah.connected" : true,
                "paymentOptions.myFatoorah.gateway" : true,
            ]
            
            if active {
                data["paymentOptions.paytabs.selected"] = false
                data["paymentOptions.vPay.selected"] = false
                data["paymentOptions.kashier.selected"] = false
                data["paymentOptions.paymob.selected"] = false
            }
            
            if let storeId = user.user?.storeId {
                saving = true
                Task {
                    try? await StoresDao().update(id:storeId, hashMap:data)
                    DispatchQueue.main.async {
                        UserInformation.shared.user?.store?.paymentOptions?.myFatoorah?.selected = active
                        UserInformation.shared.user?.store?.paymentOptions?.myFatoorah?.apiKey = apiKey
                        
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
