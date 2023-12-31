//
//  StoreSocial.swift
//  Vondera
//
//  Created by Shreif El Sayed on 25/06/2023.
//

import SwiftUI
import AlertToast
import LoadingButton

struct StoreSocial: View {
    var store:Store
    @ObservedObject var viewModel:StoreSocialViewModel
    @Environment(\.presentationMode) private var presentationMode
    
    init(store: Store) {
        self.store = store
        self.viewModel = StoreSocialViewModel(store: store)
    }
    
    var body: some View {
        List {
            HStack {
                Image("facebook")
                    .resizable()
                    .frame(width: 40, height: 40)
                
                FloatingTextField(title: "Facebook Link", text: $viewModel.fb, required: nil, keyboard: .URL)
            }
            
            HStack {
                Image("instagram")
                    .resizable()
                    .frame(width: 40, height: 40)
                
                FloatingTextField(title: "Instagram Link", text: $viewModel.insta, required: nil, keyboard: .URL)

            }
            
            HStack {
                Image("tiktok")
                    .resizable()
                    .frame(width: 40, height: 40)
                
                FloatingTextField(title: "Tik Tok Link", text: $viewModel.tiktok, required: nil, keyboard: .URL)
            }
        }
        .navigationTitle("Social")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Update") {
                    save()
                }
                .disabled(viewModel.isSaving)
            }
        }
        .navigationBarBackButtonHidden(viewModel.isSaving)
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
    
    func save() {
        Task {
            await viewModel.updateName()
        }
    }
}

struct StoreSocial_Previews: PreviewProvider {
    static var previews: some View {
        StoreSocial(store: Store.example())
    }
}
