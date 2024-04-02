//
//  StoreCommunications.swift
//  Vondera
//
//  Created by Shreif El Sayed on 25/06/2023.
//

import SwiftUI
import AlertToast


struct StoreCommunications: View {
    var store:Store
    @ObservedObject var viewModel:StoreCommunicationsViewModel
    @Environment(\.presentationMode) private var presentationMode
    
    init(store: Store) {
        self.store = store
        self.viewModel = StoreCommunicationsViewModel(store: store)
    }
    
    var body: some View {
        Form {
            Section("Contact") {
                FloatingTextField(title: "Business phone number", text: $viewModel.phone, caption: "We will use this number to contact you for any inquaries", required: true)
                    .keyboardType(.phonePad)
                
            }
            
            Section("Address") {
                Picker("Government", selection: $viewModel.gov) {
                    ForEach(GovsUtil().govs, id: \.self) { option in
                        Text(option)
                    }
                }
                
                FloatingTextField(title: "Address", text: $viewModel.address, caption: "We won't share your address, we collect it for analyze perpose", required: true, multiLine: true)
                
            }
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
            .navigationTitle("Communication")
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

struct StoreCommunications_Previews: PreviewProvider {
    static var previews: some View {
        StoreCommunications(store: Store.example())
    }
}
