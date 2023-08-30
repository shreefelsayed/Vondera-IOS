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
        ScrollView(showsIndicators: false) {
            VStack(alignment: .center, spacing: 12) {
                
                HStack {
                    Image("facebook")
                        .resizable()
                        .frame(width: 40, height: 40)
                    
                    TextField("Facebook Link", text: $viewModel.fb)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.URL)
                }
                
                HStack {
                    Image("instagram")
                        .resizable()
                        .frame(width: 40, height: 40)
                    
                    TextField("Instagram Link", text: $viewModel.insta)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.URL)
                }
                
                HStack {
                    Image("website")
                        .resizable()
                        .frame(width: 40, height: 40)
                    
                    TextField("Your website", text: $viewModel.web)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.URL)
                }
                
                HStack {
                    Image("tiktok")
                        .resizable()
                        .frame(width: 40, height: 40)
                    
                    TextField("Tik Tok Link", text: $viewModel.tiktok)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.URL)
                }
                
                LoadingButton(action: {
                    save()
                }, isLoading: $viewModel.isSaving, style: LoadingButtonStyle(width: .infinity, cornerRadius: 16, backgroundColor: .accentColor, loadingColor: .white)) {
                    Text("Update Social Links")
                        .foregroundColor(.white)
                }
            }
            
        }
        .padding()
        .navigationTitle("Social")
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

struct StoreSocial_Previews: PreviewProvider {
    static var previews: some View {
        StoreSocial(store: Store.example())
    }
}
