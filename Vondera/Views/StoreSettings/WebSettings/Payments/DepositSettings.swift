//
//  DepositSettings.swift
//  Vondera
//
//  Created by Shreif El Sayed on 02/12/2023.
//

import SwiftUI
import AlertToast

struct DepositSettings: View {
    var storeId:String
    
    @State private var isSaving = false
    @State private var isLoading = false
    @Environment(\.presentationMode) private var presentationMode

    @State private var value:String = ""
    @State private var active = false
    @State private var type = "percent" // “percent”, “amount”
        
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Toggle("Enable Deposit", isOn: $active)
                    .bold()
                
                Spacer().frame(height: 24)
                
                Text("Deposit Type")
                    .bold()
                
                HStack {
                    RadioButton(text: "Perecent", isSelected: type == "percent") {
                        type = "percent"
                    }
                    
                    Spacer()
                    
                    RadioButton(text: "Constant Amount", isSelected: type == "amount") {
                        type = "amount"
                    }
                }
                
                Spacer().frame(height: 24)
                
                FloatingTextField(title: type == "amount" ? "Deposit amount" : "Deposit Percent",
                                  text: $value,
                                  caption: "This is your Card live integration id from Paymob Developer Page",
                                  required: true,
                                  keyboard: .numberPad)
                
        
            }
            .padding()
        }
        .scrollIndicators(.hidden)
        .navigationTitle("Deposit Options")
        .willLoad(loading: isLoading)
        .willProgress(saving: isSaving)
        .task {
            await fetch()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    Task { await save() }
                }
            }
        }
        
    }
    
    private func fetch() async {
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        do {
            let result = try await StoresDao().getStore(uId: storeId)
            DispatchQueue.main.async {
                self.updateUI(options: result?.depositOptions)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func updateUI(options:DepsoitOptions?) {
        self.value = options?.value.toString() ?? ""
        self.type = options?.type ?? "percent"
        self.active = options?.active ?? false
        self.isLoading = false
    }
    
    private func validate() -> Bool {
        if value.toDoubleOrZero() == 0 {
            ToastManager.shared.showToast(msg: "Value can't be Zero", toastType: .error)
            return false
        }
        
        if type == "percent" {
            if value.toDoubleOrZero() < 1 || value.toDoubleOrZero() > 99 {
                ToastManager.shared.showToast(msg: "Value must be between 1% and 99%", toastType: .error)
                return false
            }
        }
        
        return true
    }
    
    private func save() async {
        guard validate() else { return }
        
        DispatchQueue.main.async { self.isSaving = true }
        
        do {
            let data:[String:Any] = [
                "depositOptions.value": value.toDoubleOrZero(),
                "depositOptions.type": type,
                "depositOptions.active": active
            ]
            
            // --> Update
            try await StoresDao().update(id: storeId, hashMap: data)
            
            DispatchQueue.main.async {
                self.isSaving = false
                self.presentationMode.wrappedValue.dismiss()
                ToastManager.shared.showToast(msg: "Settings updated successfully", toastType: .success)
            }
        } catch {
            DispatchQueue.main.async {
                self.isSaving = false
                ToastManager.shared.showToast(msg: error.localizedDescription.localize(), toastType: .error)
            }
        }
    }
    
}
