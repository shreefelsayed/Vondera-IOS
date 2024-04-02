//
//  ProductVarients.swift
//  Vondera
//
//  Created by Shreif El Sayed on 02/07/2023.
//

import SwiftUI
import AlertToast

struct ProductVarients: View {
    var product:StoreProduct
    @ObservedObject var viewModel:ProductVarientsViewModel
    @Environment(\.presentationMode) private var presentationMode
    
    init(product: StoreProduct) {
        self.product = product
        self.viewModel = ProductVarientsViewModel(product: product)
    }
    
    var body: some View {
        List {
            ForEach($viewModel.listTitles.indices, id: \.self) { i in
                Section {
                    FloatingTextField(title: "Variant Title", text: $viewModel.listTitles[i], required: nil, autoCapitalize: .words)
                    
                    OptionsView(items: $viewModel.listOptions[i])
                } header: {
                    HStack {
                        Text("Option \(i + 1) : \(viewModel.listTitles[i])")
                        
                        Spacer()
                        
                        Button(role: .destructive) {
                            withAnimation {
                                viewModel.deleteVarient(i : i)
                            }
                        } label: {
                            Text("Delete")
                        }
                    }
                }
            }
            
            HStack {
                Button {
                    withAnimation {
                        viewModel.addVarient()
                    }
                } label: {
                    Label("New Option", systemImage: "plus")
                }
                Spacer()
            }
            
        }
        .willProgress(saving: viewModel.isSaving)
        .navigationBarBackButtonHidden(viewModel.isSaving)
        .navigationTitle("Product Varients")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Update") {
                    update()
                }
                .disabled(viewModel.isSaving)
            }
        }
        .onReceive(viewModel.viewDismissalModePublisher) { shouldDismiss in
            if shouldDismiss {
                self.presentationMode.wrappedValue.dismiss()
            }
        }
        .toast(isPresenting: Binding(value: $viewModel.msg)){
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

struct OptionsView : View {
    @Binding var items: [String]
    @State private var newOption: String = ""
    
    var body: some View {
        ForEach($items, id: \.self) { item in
            if let index = items.firstIndex(of: item.wrappedValue) {
                FloatingTextField(title: "Option \(index + 1)", text: item, required: nil, autoCapitalize: .words, isDiabled: false)
                    .listRowSeparator(.hidden)
                    .listRowSpacing(6)
            }
        }
        .onMove { indexSet, index in
            withAnimation {
                items.move(fromOffsets: indexSet, toOffset: index)
            }
        }
        .onDelete { index in
            withAnimation {
                items.remove(atOffsets: index)
            }
        }
                
        HStack(alignment: .center) {
            FloatingTextField(title: "Option \(items.count + 1)", text: $newOption, required: nil, autoCapitalize: .words)
            
            Button {
                if newOption.isBlank {
                    return
                }
                
                items.append(newOption)
                newOption = ""
            } label: {
                Image(systemName: "plus")
            }
            .disabled(newOption.isBlank)
            .padding(.horizontal, 6)
        }
    }
}

#Preview {
    ProductVarients(product: StoreProduct.example())
}
