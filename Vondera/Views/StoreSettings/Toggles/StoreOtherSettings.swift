//
//  StoreOtherSettings.swift
//  Vondera
//
//  Created by Shreif El Sayed on 14/03/2024.
//

import SwiftUI

struct StoreOtherSettings: View {
    @State private var isLoading = false
    @State private var isSaving = false
    @Environment(\.presentationMode) private var presentationMode

    @ObservedObject private var myUser = UserInformation.shared
    @State private var whatsapp = true
    
    var body: some View {
        List {
            VStack (alignment: .leading) {
                Toggle("Local Whatsapp", isOn: $whatsapp)
                
                Text("Enable sending a WhatsApp message to your client from your phone, once the order is submitted")
                    .font(.caption)
            }
        }
        .task {
            await getData()
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
        .navigationTitle("Other Settings")
    }
    
    func save() {
        self.isSaving = true
        
        if let storeId = myUser.user?.storeId {
            Task {
                let data = [
                    "localWhatsapp": whatsapp
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
            self.whatsapp = store.localWhatsapp ?? true
        }
        
        self.isLoading = false
    }
}

#Preview {
    StoreOtherSettings()
}
