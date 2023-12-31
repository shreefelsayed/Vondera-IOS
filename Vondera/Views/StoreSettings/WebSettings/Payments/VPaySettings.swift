//
//  Paytab.swift
//  Vondera
//
//  Created by Shreif El Sayed on 31/10/2023.
//

import SwiftUI

struct VPay: View {
    @State var active = true
    @ObservedObject var user = UserInformation.shared
    
    
    @Environment(\.presentationMode) private var presentationMode
    @State var saving = false
    @State var msg:String?
    
    var body: some View {
        List {
            Toggle("Default Payment Gateway", isOn: $active)
            
            Text("")
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
