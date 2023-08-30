//
//  StoreCommunications.swift
//  Vondera
//
//  Created by Shreif El Sayed on 25/06/2023.
//

import SwiftUI
import AlertToast
import LoadingButton

struct StoreCommunications: View {
    var store:Store
    @ObservedObject var viewModel:StoreCommunicationsViewModel
    @Environment(\.presentationMode) private var presentationMode
    
    init(store: Store) {
        self.store = store
        self.viewModel = StoreCommunicationsViewModel(store: store)
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .center, spacing: 12) {
                TextField("Phone Number", text: $viewModel.phone)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)
                
                Text("This will not appear to your customers, we just need it so we can contact you.")
                    .font(.caption)
                
                Divider()
                
                VStack(alignment: .leading) {
                    Text("Address")
                        .font(.title2)
                        .bold()
                    
                    TextField("Address", text: $viewModel.address, axis: .vertical)
                        .lineLimit(5, reservesSpace: true)
                        .textFieldStyle(.roundedBorder)
                }
               
                
                LoadingButton(action: {
                    save()
                }, isLoading: $viewModel.isSaving, style: LoadingButtonStyle(width: .infinity, cornerRadius: 16, backgroundColor: .accentColor, loadingColor: .white)) {
                    Text("Save")
                        .foregroundColor(.white)
                }
            }
            
        }
        .padding()
        .navigationTitle("Communications")
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

struct StoreCommunications_Previews: PreviewProvider {
    static var previews: some View {
        StoreCommunications(store: Store.example())
    }
}
