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
            // DESC
            Text("Check the governments you ship to, and enter their shipping fees")
                .font(.body)
            
            // HEADER
            HStack {
                Text("Active")
                
                Spacer()
                
                Text("Government")
                
                Spacer()
                
                Text("Shipping Price")
            }
            
            // GOVS
            ForEach(govManager.getDefaultCourierList(), id: \.self) { item in
                HStack(alignment: .center) {
                    Toggle(isOn: Binding(items: $viewModel.list, currentItem: item)) {
                        EmptyView()
                    }
                    .frame(width: 60)
                        

                    Text(item.govName)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity)
                        //.frame(maxHeight:  .infinity)
                        .padding(.vertical, 6)
                    
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
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle("Areas")
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


#Preview {
    NavigationStack {
        StoreShipping(storeId: Store.example().ownerId)
    }
}
