//
//  WebsiteLanguage.swift
//  Vondera
//
//  Created by Shreif El Sayed on 09/11/2024.
//

import SwiftUI

struct WebsiteLanguage: View {
    var storeId:String
    
    @State private var supportedLanguages = ["ar"]
    @State private var isLoading = false
    @State private var isSaving = false
    
    @Environment(\.presentationMode) private var presentationMode

    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("Choose your website display languages")
                    .font(.title2)
                    .bold()
                
                
                buildLanguageRow("Arabic", "ar", .imgAr)
                
                buildLanguageRow("English", "en", .imgEn)
            }
            .padding()
        }
        .task { await fetch() }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    Task { await update() }
                }
            }
        }
        .scrollIndicators(.hidden)
        .willLoad(loading: isLoading)
        .willProgress(saving: isSaving)
        .withPaywall(accessKey: .globalSite, presentation: presentationMode)
        
    }
    
    func update() async {
        DispatchQueue.main.async { self.isSaving = true }
        
        do {
            let data:[String:Any] = [
                "siteData.websiteLanguage" : supportedLanguages
            ]
            
            try await StoresDao().update(id: storeId, hashMap: data)
            
            DispatchQueue.main.async {
                self.isSaving = false
                ToastManager.shared.showToast(msg: "Languages Updated", toastType: .success)
                self.presentationMode.wrappedValue.dismiss()
            }
        } catch {
            DispatchQueue.main.async { self.isSaving = false }
            ToastManager.shared.showToast(msg: error.localizedDescription.localize(), toastType: .error)
        }
    }
    
    func fetch() async {
        DispatchQueue.main.async { self.isLoading = true }
        do {
            let store = try await StoresDao().getStore(uId: storeId)
            guard let store = store else { return }
            
            DispatchQueue.main.async {
                self.updateUI(store)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func updateUI(_ store:Store) {
        self.supportedLanguages = store.siteData?.websiteLanguage ?? ["ar", "en"]
        self.isLoading = false
    }
    
    @ViewBuilder
    func buildLanguageRow(_ name:LocalizedStringKey, _ id:String, _ flag:ImageResource) -> some View {
        HStack {
            CheckBoxView(checked: Binding<Bool>(
                get: { supportedLanguages.contains(id) },
                set: { isChecked in
                    if isChecked {
                        supportedLanguages.append(id)
                    } else {
                        supportedLanguages.removeAll { $0 == id }
                    }
                }
            ))
            
            Image(flag)
                .resizable()
                .frame(width: 32, height: 24)
                .scaledToFit()
            
            Text(name)
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

