//
//  StoreLogo.swift
//  Vondera
//
//  Created by Shreif El Sayed on 25/06/2023.
//

import SwiftUI
import AlertToast
import LoadingButton

import NetworkImage

struct StoreLogo: View {
    var store:Store
    @ObservedObject var viewModel:StoreLogoViewModel
    @Environment(\.presentationMode) private var presentationMode
    
    init(store: Store) {
        self.store = store
        self.viewModel = StoreLogoViewModel(store: store)
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .center) {
                if viewModel.selectedImage == nil {
                    NetworkImage(url: URL(string: store.logo ?? "")) { image in
                      image.centerCropped()
                    } placeholder: {
                      ProgressView()
                    } fallback: {
                        Image("app_icon")
                            .resizable()
                            .frame(width: 120, height: 120)
                    }
                    .background(Color.gray)
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                    .overlay(alignment: .center) {
                        Image(systemName: "photo.fill.on.rectangle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .opacity(0.4)
                    }.onTapGesture {
                        viewModel.pickPhotos()
                    }
                } else {
                    Image(uiImage: viewModel.selectedImage)
                        .resizable()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .overlay(alignment: .center) {
                            Image(systemName: "photo.fill.on.rectangle.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .opacity(0.4)
                        }.onTapGesture {
                            viewModel.pickPhotos()
                        }
                }
                
                
                Spacer().frame(height: 20)
                
                Text("The store logo is used to identify your store in the app. It will be displayed on the store page and in the store list. The logo should be a square image with a minimum size of 512x512 pixels. The recommended size is 1024x1024 pixels. The logo will be displayed at a size of 120x120 pixels.")
                    .font(.caption)
                
                
                LoadingButton(action: {
                    save()
                }, isLoading: $viewModel.isSaving, style: LoadingButtonStyle(width: .infinity, cornerRadius: 16, backgroundColor: .accentColor, loadingColor: .white)) {
                    Text("Update Logo")
                        .foregroundColor(.white)
                }
            }
        }
        .padding()
        .navigationTitle("Store Logo")
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
        if viewModel.selectedImage == nil {
            viewModel.pickPhotos()
            return
        }
        
        Task {
            await viewModel.saveNewLogo()
        }
    }
}

struct StoreLogo_Previews: PreviewProvider {
    static var previews: some View {
        StoreLogo(store: Store.example())
    }
}
