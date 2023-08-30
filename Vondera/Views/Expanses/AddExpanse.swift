//
//  AddExpanse.swift
//  Vondera
//
//  Created by Shreif El Sayed on 27/06/2023.
//

import SwiftUI
import AlertToast

struct AddExpanse: View {
    var storeId:String
    @ObservedObject var viewModel:AddExpansesViewModel
    @Binding var currentList:[Expense]
    @Environment(\.presentationMode) private var presentationMode
    
    init(storeId: String, currentList: Binding<[Expense]>) {
        self.storeId = storeId
        self._currentList = currentList
        self.viewModel = AddExpansesViewModel(storeId: storeId)
    }
    
    var body: some View {
        ScrollView (showsIndicators: false) {
            VStack(alignment: .leading, spacing: 12) {
                TextField("Price", text: $viewModel.price)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)
                
                TextField("Address", text: $viewModel.desc, axis: .vertical)
                    .lineLimit(5, reservesSpace: true)
                    .textFieldStyle(.roundedBorder)
            }
        }
        .padding()
        .navigationTitle("New Expanse")
        .willProgress(saving: viewModel.isSaving)
        .onReceive(viewModel.viewDismissalModePublisher) { shouldDismiss in
            if shouldDismiss {
                if viewModel.newItem != nil {
                    currentList.insert(viewModel.newItem!, at: 0)
                }
                
                self.presentationMode.wrappedValue.dismiss()
            }
        }
        .toast(isPresenting: $viewModel.showToast){
            AlertToast(displayMode: .banner(.slide),
                       type: .regular,
                       title: viewModel.msg)
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
