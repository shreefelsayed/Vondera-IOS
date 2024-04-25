//
//  StoreProductSettings.swift
//  Vondera
//
//  Created by Shreif El Sayed on 14/03/2024.
//

import SwiftUI

struct StoreProductSettings: View {
    @State private var isLoading = false
    @State private var isSaving = false
    @Environment(\.presentationMode) private var presentationMode

    @ObservedObject private var myUser = UserInformation.shared
    
    @State private var indec:Double = 25
    @State private var editPrice = false
    
    var body: some View {
        List {
            VStack(alignment: .leading) {
                Text("Low Stocks Indecator")
                
                HStack {
                    Text("Min Quantity")
                    
                    Spacer()
                    
                    FloatingTextField(title: "Quantity", text: .constant(""), required: nil, isNumric: true, number: $indec)
                        .frame(width: 60, height: 50)
                    
                }
                
                Text("Set up an indecator to track your low stocks")
                    .font(.caption)
            }
            VStack(alignment: .leading) {
                Toggle("Product Editable Prices", isOn: $editPrice)
                
                Text("Your employees can edit the product prices on the checkout proccess")
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
        .navigationTitle("Products Settings")
    }
    
    func save() {
        self.isSaving = true
        
        if let storeId = myUser.user?.storeId {
            Task {
                let data = [
                    "almostOut": indec,
                    "canEditPrice": editPrice
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
            self.indec = Double(store.almostOut ?? 20)
            self.editPrice = store.canEditPrice ?? false
        }
        
        self.isLoading = false
    }
}

#Preview {
    StoreProductSettings()
}
