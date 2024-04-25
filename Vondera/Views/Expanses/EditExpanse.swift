//
//  EditExpanse.swift
//  Vondera
//
//  Created by Shreif El Sayed on 27/06/2023.
//

import SwiftUI
import AlertToast

struct EditExpanse: View {
    var expanse:Expense
    var onUpdated:((Expense) -> ())
    
    
    @State private var price = 0.0
    @State private var desc = ""
    
    @State private var isSaving = false
    @State private var msg:LocalizedStringKey?
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        List {
            FloatingTextField(title: "Amount", text: .constant(""), caption: "How much have you spents", required: true, isNumric: true, number: $price)
            
            FloatingTextField(title: "Description", text: $desc, caption: "Describe what is this expanses for ex (Marketing fees, employee salary)", required: true, multiLine: true)
        }
        .navigationTitle("Edit Expanse")
        .willProgress(saving: isSaving)
        .toast(isPresenting: Binding(value: $msg)){
            AlertToast(displayMode: .banner(.slide),
                       type: .regular,
                       title: msg?.toString())
        }
        .task {
            price = expanse.amount
            desc = expanse.description
        }
        .navigationBarBackButtonHidden(isSaving)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Update") {
                    Task {
                        await save()
                    }
                }
            }
        }
    }
    
    func save() async {
        guard check() else {
            return
        }
        
        guard let storeId = UserInformation.shared.user?.storeId else {
            return
        }
        
        do {
            isSaving = true
            let data:[String:Any] = ["description" : desc, "amount" : price]
            try await ExpansesDao(storeId: storeId).update(id: expanse.id, hashMap: data)
            DispatchQueue.main.async {
                var exp = expanse
                exp.amount = price
                exp.description = desc
                print("Expanse Updated !")
                isSaving = false
                onUpdated(exp)
                self.presentationMode.wrappedValue.dismiss()
            }
            
        } catch {
            msg = error.localizedDescription.localize()
            isSaving = false
        }
    }
    
    func check() -> Bool {
        guard !desc.isBlank else {
            msg = "Please but a describtion for the amount"
            return false
        }
        
        guard price > 0 else {
            msg = "Please enter a valid amount"
            return false
        }
        
        return true
    }
}
