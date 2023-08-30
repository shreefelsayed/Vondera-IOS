//
//  NewCourier.swift
//  Vondera
//
//  Created by Shreif El Sayed on 27/06/2023.
//

import SwiftUI
import AlertToast

struct NewCourier: View {
    var storeId:String
    @ObservedObject var viewModel:NewCourierViewModel
    @Binding var currentList:[Courier]
    @Environment(\.presentationMode) private var presentationMode
    
    init(storeId: String, currentList: Binding<[Courier]>) {
        self.storeId = storeId
        self._currentList = currentList
        self.viewModel = NewCourierViewModel(storeId: storeId)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                // --> Main Data
                Text("Courier info")
                    .font(.title2)
                    .bold()
                
                TextField("Courier Name", text: $viewModel.name)
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.words)
                    
                TextField("Courier Phone", text: $viewModel.phone)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.phonePad)
                        
                Spacer().frame(height: 26)
                
                Text("Shipping Prices")
                    .font(.title2)
                    .bold()
                
                // --> Item List
                ForEach(viewModel.items, id: \.self) { item in
                    VStack {
                        HStack {
                            Text(item.govName)
                            Spacer()
                            TextField("Price", text: Binding(
                                get: { String(item.price) },
                                set: { newValue in
                                    if let newPrice = Int(newValue) {
                                        // Update the price of the item
                                        if let index = viewModel.items.firstIndex(of: item) {
                                            viewModel.items[index].price = newPrice
                                        }
                                    }
                                }
                            ))
                            .frame(width: 60)
                        }
                        
                        Divider()
                    }
                    
                }

            }
        }
        .padding()
        .navigationTitle("New Courier")
        .onReceive(viewModel.viewDismissalModePublisher) { shouldDismiss in
            if shouldDismiss {
                if viewModel.newItem != nil {
                    currentList.append(viewModel.newItem!)
                }
                
                self.presentationMode.wrappedValue.dismiss()
            }
        }
        .toast(isPresenting: $viewModel.showToast){
            AlertToast(displayMode: .banner(.slide),
                       type: .regular,
                       title: viewModel.msg)
        }
        .willProgress(saving: viewModel.isSaving)
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
