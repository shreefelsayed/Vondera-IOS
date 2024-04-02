//
//  OrderSettings.swift
//  Vondera
//
//  Created by Shreif El Sayed on 14/03/2024.
//

import SwiftUI

struct StoreOrderSettings: View {
    @State private var isLoading = false
    @State private var isSaving = false
    @Environment(\.presentationMode) private var presentationMode

    @ObservedObject private var myUser = UserInformation.shared
    
    @State private var localOrder = true
    @State private var localPickup = true
    @State private var prepaidLocal = true
    @State private var attachments = true
    @State private var reset = true

    var body: some View {
        List {
            VStack(alignment: .leading) {
                Toggle("Enable local orders", isOn: $localOrder)
                
                Text("This is enabled by default, if you turn this off no one will be able to create new orders")
                    .font(.caption)
            }
            
            VStack(alignment: .leading) {
                Toggle("Disable local orders pickup", isOn: $localPickup)
                
                Text("This is turned off by default, enabling it will add the option to pickup local orders")
                    .font(.caption)
            }
            
            Toggle("Enable Prepaid orders", isOn: $prepaidLocal)
            
            Toggle("Enable attachments in local orders", isOn: $attachments)
            
            VStack(alignment: .leading) {
                Toggle("Employees can reset orders", isOn: $reset)
                
                Text("Can worker account reset orders to it's original state ?")
                    .font(.caption)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Update") {
                    save()
                }
                .disabled(isSaving || isLoading)
            }
        }
        .willProgress(saving: isSaving)
        .willLoad(loading: isLoading)
        .task {
            await getData()
        }
        .navigationTitle("Order Settings")
    }
    
    func save() {
        self.isSaving = true
        
        if let storeId = myUser.user?.storeId {
            Task {
                let data = [
                    "canOrder" : localOrder,
                    "offlineStore" : !localPickup,
                    "canPrePaid" : prepaidLocal,
                    "orderAttachments" : attachments,
                    "canWorkersReset" : reset
                ]
                
                // --> Save the data
                do {
                    try await StoresDao().update(id: storeId, hashMap: data)
                    ToastManager.shared.showToast(msg: "Settings updated", toastType: .success)
                    self.presentationMode.wrappedValue.dismiss()
                } catch {
                    ToastManager.shared.showToast(msg: error.localizedDescription.localize(), toastType: .error)
                }
                
                self.isSaving = false
            }
        }
    }
    func getData() async {
        self.isLoading = true
        if let id = myUser.getUser()?.id {
            if let user = try? await UsersDao().getUserWithStore(userId: id) {
                myUser.updateUser(user)
            }
        }
        
        // --> Update the data
        if let store = myUser.getUser()?.store {
            self.localOrder = store.canOrder ?? true
            self.localPickup = !(store.offlineStore ?? false)
            self.prepaidLocal = store.canPrePaid ?? false
            self.attachments = store.orderAttachments ?? false
            self.reset = store.canWorkersReset ?? false
        }
        
        self.isLoading = false
    }
}

#Preview {
    NavigationStack {
        StoreOrderSettings()
    }
}
