//
//  StoreEditName.swift
//  Vondera
//
//  Created by Shreif El Sayed on 25/06/2023.
//

import SwiftUI
import AlertToast
import LoadingButton


struct StoreEditName: View {
    var store:Store
    @ObservedObject var viewModel:StoreEditNameViewModel
    @Environment(\.presentationMode) private var presentationMode
    
    init(store: Store) {
        self.store = store
        self.viewModel = StoreEditNameViewModel(store: store)
    }
    
    var body: some View {
        Form {
            Section("Name & Slogan") {
                FloatingTextField(title: "Store Name", text: $viewModel.name, caption: "This is your store name, it will be printed on the receipts and in your website, it can be changed later", required: true)
                    .textInputAutocapitalization(.words)
                
                FloatingTextField(title: "Slogan", text: $viewModel.slogan, caption: "Your store slogan, it will be shown on your receipts and in your website", required: false)
                    .textInputAutocapitalization(.words)
                
            }
        }
        .navigationTitle("Name & Slogan")
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
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Text("Save")
                    .bold()
                    .onTapGesture {
                        save()
                    }
            }
        }
        
    }
    
    func save() {
        Task {
            await viewModel.updateName()
        }
    }
}

struct StoreEditName_Previews: PreviewProvider {
    static var previews: some View {
        StoreEditName(store: Store.example())
    }
}
