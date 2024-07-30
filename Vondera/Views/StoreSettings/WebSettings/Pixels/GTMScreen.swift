//
//  GTMScreen.swift
//  Vondera
//
//  Created by Shreif El Sayed on 28/03/2024.
//

import SwiftUI

struct GTMScreen: View {
    @State private var gtm = ""
    @State private var isLoading = false
    @State private var isSaving = false
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        VStack(alignment: .leading) {
            
            FloatingTextField(title: "GTM ID", text: $gtm, caption: "Ex (GTM-347934)", required: nil)

            Spacer().frame(height: 48)

            
            Text("Google Tag Manager is a tag management system (TMS) that allows you to quickly and easily update measurement codes and related code fragments collectively known as tags on your website or mobile app. Once the small segment of Tag Manager code has been added to your project, you can safely and easily deploy analytics and measurement tag configurations from a web-based user interface.")
                .font(.caption)
            
            
            Spacer()
        }
        .padding()
        .willLoad(loading: isLoading)
        .willProgress(saving: isSaving, msg: "Updating ...")
        .task {
            await fetchData()
        }
        .toolbar {
            Button("Update") {
                Task {
                    await update()
                }
            }
            .disabled(isSaving || isLoading)
        }
        .navigationTitle("Google tag manager")
        .withPaywall(accessKey: .pixels, presentation: presentationMode)

    }
    
    private func update() async {
        guard let storeId = UserInformation.shared.user?.storeId else {
            return
        }
        
        self.isSaving = true
        do {
            try await StoresDao().update(id: storeId, hashMap: ["gtm": gtm])
            DispatchQueue.main.async {
                self.isSaving = false
                presentationMode.wrappedValue.dismiss()
            }
        } catch {
            ToastManager.shared.showToast(msg: error.localizedDescription.localize(), toastType: .error)
        }
    }
    
    private func fetchData() async {
        guard let storeId = UserInformation.shared.user?.storeId else {
            return
        }
        
        self.isLoading = true
        
        do {
            let store = try await StoresDao().getStore(uId: storeId)
            guard let store = store else { return }
            DispatchQueue.main.async {
                self.gtm = store.gtm ?? ""
                self.isLoading = false
            }
        } catch {
            ToastManager.shared.showToast(msg: error.localizedDescription.localize(), toastType: .error)
        }
    }
}

#Preview {
    GTMScreen()
}
