//
//  StoreShipping.swift
//  Vondera
//
//  Created by Shreif El Sayed on 06/07/2023.
//

import SwiftUI
import AlertToast

struct StoreShipping: View {
    var storeId:String
    var govManager = GovsUtil()
    
    @ObservedObject var viewModel:StoreShippingViewModel
    @Environment(\.presentationMode) private var presentationMode
    
    init(storeId:String) {
        self.storeId = storeId
        self.viewModel = StoreShippingViewModel(storeId: storeId)
    }
    
    var body: some View {
        List {
            HStack {
                Text("Government")
                
                Spacer()
                
                Text("Shipping Price")
            }
            
            
            ForEach(govManager.getDefaultCourierList(), id: \.self) { item in
                HStack(alignment: .center) {
                    Toggle("\(item.govName)", isOn: Binding(
                        get: {
                            viewModel.list.contains { $0 == item }
                        },
                        set: { isChecked in
                            if isChecked {
                                if !viewModel.list.contains(item) {
                                    viewModel.list.append(item)
                                }
                            } else {
                                viewModel.list.removeAll { $0 == item }
                            }
                        }))
                    
                    if let selectedItem = viewModel.list.first(where: { $0 == item }) {
                        TextField("Price", value: Binding(
                                        get: { viewModel.list[viewModel.list.firstIndex(of: selectedItem)!].price },
                                        set: { newValue in
                                            if let index = viewModel.list.firstIndex(of: selectedItem) {
                                                viewModel.list[index].price = newValue
                                            }
                                        }
                        ), formatter: NumberFormatter())
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 60)
                    }
                }
            }
        }
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
