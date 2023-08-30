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
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 12) {
                // --> Item List
                ForEach($viewModel.items, id: \.self) { item in
                    VStack {
                        HStack {
                            Text(item.govName.wrappedValue)
                            Spacer()
                            TextField("Price", value: item.price, formatter: NumberFormatter())
                                .frame(width: 60)
                        }
                        
                        Divider()
                    }
                }
            }
            .isHidden(viewModel.isLoading)
            
        }
        .padding()
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
