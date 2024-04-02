//
//  Paytab.swift
//  Vondera
//
//  Created by Shreif El Sayed on 31/10/2023.
//

import SwiftUI

struct Paytab: View {
    @State var profileId = ""
    @State var apiKey = ""
    @State var active = true
    @ObservedObject var user = UserInformation.shared
    
    var signLink = "https://merchant-egypt.paytabs.com/merchant/reg/rkjnlb6ggljh6bwjtnbt6dbbddbn6b"
    
    @Environment(\.presentationMode) private var presentationMode
    @State var saving = false
    @State var msg:String?
    
    var body: some View {
        List {
            FloatingTextField(title: "Profile Id", text: $profileId, caption: "This is the profile id found in your paytabs dashboard", required: true, keyboard: .numberPad)
            
            FloatingTextField(title: "API Key", text: $apiKey, caption: "The API Key found in your developers / key in the dashboard", required: true, keyboard: .default)
            
            Toggle("Default Payment Gateway", isOn: $active)
            
            
            Text("Don't have a paytab account ? Sign Up now !")
                .foregroundColor(Color.accentColor)
                .multilineTextAlignment(.center)
                .onTapGesture {
                    if let url = URL(string: signLink) {
                        UIApplication.shared.open(url)
                    }
                }
        }
        .task {
            if let paytabs = user.user?.store?.paymentOptions?.paytabs {
                profileId = paytabs.profile_id ?? ""
                apiKey = paytabs.apiKey ?? ""
                active = paytabs.selected ?? false
            }
        }
        .willProgress(saving: saving)
        .navigationTitle("Paytabs")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Connect") {
                    connect()
                }
                
                Link(destination: URL(string: "https://www.youtube.com/watch?v=x2Cod35VBd8&pp=ygUHVm9uZGVyYQ%3D%3D")!) {
                    Text("Help")
                }
            }
        }
    }
    
    func connect() {
        guard !profileId.isBlank, !apiKey.isBlank else {
            msg = "Please fill the required data"
            return
        }
        
        Task {
            var data = [
                "paymentOptions.paytabs.profile_id" : profileId,
                "paymentOptions.paytabs.apiKey" : apiKey,
                "paymentOptions.paytabs.selected" : active,
                "paymentOptions.paytabs.connected" : true,
                "paymentOptions.paytabs.gateway" : true,
            ]
            
            if active {
                data["paymentOptions.paymob.selected"] = false
                data["paymentOptions.vPay.selected"] = false
                data["paymentOptions.kashier.selected"] = false
                data["paymentOptions.myFatoorah.selected"] = false
            }
            
            if let storeId = user.user?.storeId {
                saving = true
                Task {
                    try? await StoresDao().update(id:storeId, hashMap:data)
                    DispatchQueue.main.async {
                        UserInformation.shared.user?.store?.paymentOptions?.paytabs?.selected = active
                        UserInformation.shared.user?.store?.paymentOptions?.paytabs?.profile_id = profileId
                        UserInformation.shared.user?.store?.paymentOptions?.paytabs?.apiKey = apiKey
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
