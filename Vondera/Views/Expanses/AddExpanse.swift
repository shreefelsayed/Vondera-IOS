//
//  AddExpanse.swift
//  Vondera
//
//  Created by Shreif El Sayed on 27/06/2023.
//

import SwiftUI
import AlertToast

struct AddExpanse: View {
    var onAdded:((Expense) -> ())

    @ObservedObject var viewModel = AddExpansesViewModel()
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        List {
            FloatingTextField(title: "Amount", text: .constant(""), caption: "How much have you spents", required: true, isNumric: true, number: $viewModel.price)
            
            FloatingTextField(title: "Description", text: $viewModel.desc, caption: "Describe what is this expanses for ex (Marketing fees, employee salary)", required: true, multiLine: true)
            
        }
        .navigationTitle("New Expanse")
        .navigationBarBackButtonHidden(viewModel.isSaving)
        .willProgress(saving: viewModel.isSaving)
        .onReceive(viewModel.viewDismissalModePublisher) { shouldDismiss in
            if shouldDismiss {
                if let newItem = viewModel.newItem {
                    onAdded(newItem)
                }
                self.presentationMode.wrappedValue.dismiss()
            }
        }
        .toast(isPresenting: Binding(value: $viewModel.msg)){
            AlertToast(displayMode: .banner(.slide),
                       type: .regular,
                       title: viewModel.msg?.toString())
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Create") {
                    Task {
                        await viewModel.save()
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        AddExpanse { item in
            
        }
    }
}
