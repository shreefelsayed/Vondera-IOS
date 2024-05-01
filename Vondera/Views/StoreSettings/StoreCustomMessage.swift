//
//  StoreCustomMessage.swift
//  Vondera
//
//  Created by Shreif El Sayed on 24/10/2023.
//

import SwiftUI

struct StoreCustomMessage: View {
    @State private var customMessage = ""
    
    @State private var label = false
    @State private var seller = false
    @State private var serial = false

    @State private var isSaving = false
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        Form {
            Section("Options") {
                Toggle("Cannot open Label", isOn: $label)
                Toggle("Print Seller name", isOn: $seller)
                Toggle("Print Shipping Serial no.", isOn: $serial)
            }
            
            Section("Custom Message") {
                FloatingTextField(title: "Custom message", text: $customMessage, caption: "This will be displayed at the end of your receipt", required: nil, multiLine: true, autoCapitalize: .words)
            }
        }
        .listStyle(.plain)
        .navigationTitle("Receipt Options")
        .willProgress(saving: isSaving)
        .navigationBarBackButtonHidden(isSaving)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    save()
                }
                .disabled(isSaving)
            }
        }
        .task {
            updateUI()
        }
        .withPaywall(accessKey: .customReceipt, presentation: presentationMode)
    }
    
    func updateUI() {
        if let store = UserInformation.shared.user?.store {
            self.customMessage = store.customMessage ?? ""
            self.label = store.cantOpenPackage ?? false
            self.seller = store.sellerName ?? false
            self.serial = store.printSerial ?? false
        }
    }
    
    
    func save() {
        Task {
            let data = [
                "customMessage": customMessage,
                "cantOpenPackage": label,
                "sellerName": seller,
                "printSerial": serial
            ]
            
            if let storeId = UserInformation.shared.user?.storeId {
                do {
                    try await StoresDao().update(id: storeId, hashMap: data)
                    DispatchQueue.main.async {
                        UserInformation.shared.user?.store?.customMessage = customMessage
                        UserInformation.shared.updateUser()
                        ToastManager.shared.showToast(msg: "Updated", toastType: .success)
                        self.presentationMode.wrappedValue.dismiss()
                    }
                } catch {
                    CrashsManager().addLogs(error.localizedDescription, "Custom Message")
                    ToastManager.shared.showToast(msg: error.localizedDescription.localize(), toastType: .error)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        StoreCustomMessage()
    }
    
}
