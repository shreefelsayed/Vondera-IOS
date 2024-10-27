//
//  WBShippedSettings.swift
//  Vondera
//
//  Created by Shreif El Sayed on 03/07/2024.
//

import SwiftUI

struct WBDeliveredSettings: View {
    @State private var msg = ""
    @State private var isActive = false
    @StateObject private var cursorPosition = CursorPosition()
    
    @State var wbInfo:WbInfo? = nil
    
    @State private var isLoading = false
    @State private var isSaving = false
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("This will send a message when an order delivered")
                    .bold()
                
                Toggle("Active this message", isOn: $isActive)
                
                
                CursorTrackingTextView(text: $msg, cursorPosition: cursorPosition)
                    .frame(height: 180)
                    .border(Color.gray)
                    .disabled(!isActive)
                
                
                Text("Insert variables : ")
                    .bold()
                
                VariablesAdder(text: $msg, cursorPosition: cursorPosition)
                
            }
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    Task { await update() }
                }
            }
        }
        .navigationTitle("Delivered Message")
        .willLoad(loading: isLoading)
        .willProgress(saving: isSaving)
        .task {
            await fetchData()
        }
        
    }
    
    private func update() async {
        guard var wbInfo = wbInfo, let storeId = UserInformation.shared.user?.storeId else { return }
        
        self.isSaving = true
        
        do {
            wbInfo.delivered = WBMessage(active: isActive, msg: msg)
            try await StoresDao().update(id: storeId, hashMap: ["wbInfo": wbInfo.asDicitionry()])
            DispatchQueue.main.async {
                ToastManager.shared.showToast(msg: "Whatsapp info updated", toastType: .success)
                self.presentationMode.wrappedValue.dismiss()
                self.isSaving = false
            }
        } catch {
            ToastManager.shared.showToast(msg: error.localizedDescription.localize(), toastType: .error)
            self.isSaving = false
        }
    }
    
    private func fetchData() async {
        self.isLoading = true
        
        guard let storeId = UserInformation.shared.user?.storeId else { return }
        
        do {
            let store = try await StoresDao().getStore(uId: storeId)
            guard let store = store else { return }
            DispatchQueue.main.async {
                self.wbInfo = store.wbInfo ?? WbInfo()
                self.isActive = store.wbInfo?.delivered?.active ?? false
                self.msg = store.wbInfo?.delivered?.msg ?? ""
                self.isLoading = false
            }
        } catch {
            print(error)
        }
    }
}
