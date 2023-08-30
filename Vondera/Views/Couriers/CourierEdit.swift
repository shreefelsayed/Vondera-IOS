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
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 12) {
                TextField("Courier Name", text: $viewModel.name)
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.words)
                    
                TextField("Courier Phone", text: $viewModel.phone)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.phonePad)
                
                Toggle("Courier Active", isOn: $viewModel.active)
                
                Text("By turning this off you will disable adding any order to this courier")
                    .font(.caption)
                
            }
            .isHidden(viewModel.isLoading)
            
        }.padding()
            .navigationTitle("Edit Employee")
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
            .toast(isPresenting: $viewModel.showToast){
                AlertToast(displayMode: .banner(.slide),
                           type: .regular,
                           title: viewModel.msg)
            }
    }
    
    func update() {
        Task {
            await viewModel.update()
        }
    }
}
