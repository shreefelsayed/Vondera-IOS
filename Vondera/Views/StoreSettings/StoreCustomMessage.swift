//
//  StoreCustomMessage.swift
//  Vondera
//
//  Created by Shreif El Sayed on 24/10/2023.
//

import SwiftUI
import AlertToast

struct StoreCustomMessage: View {
    @State private var customMessage = ""
    @State private var msg:LocalizedStringKey?
    @State private var isSaving = false
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        Form {
            FloatingTextField(title: "Custom text", text: $customMessage, caption: "This will be displayed at the end of your receipt", required: false, multiLine: true, autoCapitalize: .words)
        }
        .navigationTitle("Custom Receipt Text")
        .willProgress(saving: isSaving)
        .navigationBarBackButtonHidden(isSaving)
        .toast(isPresenting: Binding(value: $msg)){
            AlertToast(displayMode: .banner(.slide),
                       type: .regular,
                       title: msg?.toString())
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    save()
                }
                .disabled(isSaving)
            }
        }
        .task {
            customMessage = UserInformation.shared.user?.store?.customMessage ?? ""
        }
    }
    
    func save() {
        Task {
            if let storeId = UserInformation.shared.user?.storeId {
                do {
                    try await StoresDao().update(id: storeId, hashMap: ["customMessage": customMessage])
                    DispatchQueue.main.async {
                        UserInformation.shared.user?.store?.customMessage = customMessage
                        UserInformation.shared.updateUser()
                        self.msg = "Updated".localize()
                        self.presentationMode.wrappedValue.dismiss()
                    }
                } catch {
                    self.msg = error.localizedDescription.localize()
                }
                
            }
            
        }
    }
}

#Preview {
    StoreCustomMessage()
}
