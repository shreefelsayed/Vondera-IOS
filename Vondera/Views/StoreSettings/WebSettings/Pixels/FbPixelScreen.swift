//
//  FbPixelScreen.swift
//  Vondera
//
//  Created by Shreif El Sayed on 28/03/2024.
//

import SwiftUI

struct FbPixelScreen: View {
    @State private var fbPixel = ""
    @State private var isLoading = false
    @State private var isSaving = false
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        VStack(alignment: .leading) {
            
            
            
            FloatingTextField(title: "Pixel ID", text: $fbPixel, caption: "Ex (4797932978324)", required: nil)
            
            Spacer().frame(height: 48)
            
            Text("The Facebook pixel is a piece of code that you place on your website. It collects data that helps you track conversions from Facebook ads, optimize ads, build targeted audiences for future ads and remarket to people who have already taken some kind of action on your website.")
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
        .navigationTitle("Facebook Pixel")
    }
    
    private func update() async {
        guard let storeId = UserInformation.shared.user?.storeId else {
            return
        }
        
        self.isSaving = true
        do {
            try await StoresDao().update(id: storeId, hashMap: ["fbPixel": fbPixel])
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
            DispatchQueue.main.async {
                self.fbPixel = store.fbPixel ?? ""
                self.isLoading = false
            }
        } catch {
            ToastManager.shared.showToast(msg: error.localizedDescription.localize(), toastType: .error)
        }
    }
}


#Preview {
    FbPixelScreen()
}
