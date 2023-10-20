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
            Text("This is the prices you charge your customers for shipping, note that if you deal with courier please add his info and shipping fees for better net profit calculations")
                .font(.body)
            
            HStack {
                Text("Government")
                
                Spacer()
                
                Text("Shipping Price")
            }
            
            
            ForEach(govManager.getDefaultCourierList(), id: \.self) { item in
                HStack(alignment: .center) {
                    Toggle("\(item.govName)", isOn: Binding(items: $viewModel.list, currentItem: item))
                    
                    let selectedItem = viewModel.list.first(where: { $0 == item })
                    
                    FloatingTextField(title: "Price", text: .constant(""), required: nil, isNumric: true, number: Binding(
                        get: { viewModel.list.contains(where: { place in
                            place.govName == item.govName
                        }) ? (selectedItem?.price ?? 0) : 0 },
                        set: { newValue in
                            if let index = viewModel.list.firstIndex(of: selectedItem!) {
                                viewModel.list[index].price = newValue
                            }
                        }
                    ), isDiabled : !viewModel.list.contains(where: { place in
                        place.govName == item.govName
                    }))
                    .frame(width: 60)
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
