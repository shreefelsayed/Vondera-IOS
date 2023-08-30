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
        ScrollView(showsIndicators: false) {
            VStack(alignment: .center, spacing: 12) {
                TextField("Store Name", text: $viewModel.name)
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.words)
                
                Divider()
                
                TextField("Store Slogan", text: $viewModel.slogan)
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.words)
                
                LoadingButton(action: {
                    save()
                }, isLoading: $viewModel.isSaving, style: LoadingButtonStyle(width: .infinity, cornerRadius: 16, backgroundColor: .accentColor, loadingColor: .white)) {
                    Text("Edit info")
                        .foregroundColor(.white)
                }
            }
            
        }
        .padding()
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
