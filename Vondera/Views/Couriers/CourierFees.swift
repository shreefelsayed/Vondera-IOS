//
//  CourierFees.swift
//  Vondera
//
//  Created by Shreif El Sayed on 03/07/2023.
//

import SwiftUI
import AlertToast

struct CourierFees: View {
    var id:String
    var storeId:String
    
    @ObservedObject var viewModel:CourierFeesViewModel
    @Environment(\.presentationMode) private var presentationMode
    
    init(id: String, storeId:String) {
        self.id = id
        self.storeId = storeId
        self.viewModel = CourierFeesViewModel(id: id, storeId: storeId)
    }
    
    var body: some View {
        List {
            ForEach($viewModel.items, id: \.govName) { item in
                VStack {
                    HStack {
                        Text(item.wrappedValue.govName)
                        
                        Spacer()
                        
                        FloatingTextField(title: "Price", text: .constant(""), required: nil, isNumric: true, number: item.price)
                            .frame(width: 80)
                    }
                }
            }
        }
        .isHidden(viewModel.isLoading)
        .listStyle(.plain)
        .navigationTitle("Shipping Prices")
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
