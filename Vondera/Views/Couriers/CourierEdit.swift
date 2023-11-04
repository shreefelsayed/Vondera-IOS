//
//  CourierEdit.swift
//  Vondera
//
//  Created by Shreif El Sayed on 03/07/2023.
//

import SwiftUI
import AlertToast

struct CourierEdit: View {
    var id:String
    var storeId:String
    
    @ObservedObject var viewModel:CourierEditViewModel
    @Environment(\.presentationMode) private var presentationMode
    
    init(id: String, storeId:String) {
        self.id = id
        self.storeId = storeId
        self.viewModel = CourierEditViewModel(id: id, storeId: storeId)
    }
    
    var body: some View {
        List {
            Section("Courier Info") {
                FloatingTextField(title: "Courier Name", text: $viewModel.name, caption: "This is the courier company name", required: true, autoCapitalize: .words)
                
                FloatingTextField(title: "Courier Contact Phone", text: $viewModel.phone, caption: "This will help you contact the courier company easily", required: true, keyboard: .phonePad)
            }
            
            Section("Active") {
                VStack(alignment: .leading) {
                    Toggle("Courier Active", isOn: $viewModel.active)
                    Text("By turning this off you will disable adding any order to this courier")
                        .font(.caption)
                }
            }
        }
        .isHidden(viewModel.isLoading)
        .navigationTitle("Edit Courier")
        .navigationBarBackButtonHidden(viewModel.isSaving)
        .overlay(alignment: .center, content: {
            ProgressView()
                .isHidden(!viewModel.isLoading)
        })
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Update") {
                    update()
                }
                .disabled(viewModel.isLoading)
            }
        }
        .willProgress(saving: viewModel.isSaving)
        .onReceive(viewModel.viewDismissalModePublisher) { shouldDismiss in
            if shouldDismiss {
                self.presentationMode.wrappedValue.dismiss()
            }
        }
        .toast(isPresenting: Binding(value: $viewModel.msg)){
            AlertToast(displayMode: .banner(.slide),
                       type: .regular,
                       title: viewModel.msg?.toString())
        }
    }
    
    func update() {
        Task {
            await viewModel.update()
        }
    }
}
